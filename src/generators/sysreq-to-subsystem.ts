/**
 * Generator: System Requirement → SubSystem Requirements (one per CI team)
 *
 * Reads a System Requirement, calls AI to identify affected CI teams,
 * creates a SubSystem Requirement per team, and comments on the parent.
 */

import { AdoClient } from "../ado-client.js";
import { callModel } from "../model-client.js";

/** CI Team → Area Path mapping */
const CI_TEAM_AREA_PATHS: Record<string, string> = {
  "PI Plan": "ItronGlobalReqs\\PI Plan",
  "Firmware": "ItronGlobalReqs\\Firmware",
  "Hardware": "ItronGlobalReqs\\Hardware",
  "Field Tools": "ItronGlobalReqs\\Itron Mobile Field Tool",
  "FW DevOps": "ItronGlobalReqs\\FW DevOps",
  "GMS": "ItronGlobalReqs\\GMS",
  "NetwAbstr": "ItronGlobalReqs\\NetwAbstr",
  "Operations": "ItronGlobalReqs\\Operations",
  "PLM": "ItronGlobalReqs\\PLM",
  "Procurement": "ItronGlobalReqs\\Procurement",
  "Regulatory": "ItronGlobalReqs\\Regulatory",
  "System Design": "ItronGlobalReqs\\System Design",
  "Manufacturing": "ItronGlobalReqs\\Manufacturing",
  "Documentation": "ItronGlobalReqs\\Documentation",
  "Test/QA": "ItronGlobalReqs\\Test-QA",
};

const SYSTEM_PROMPT = `You are a senior Systems Engineer at Itron. You decompose System Requirements into SubSystem Requirements, one per affected CI (Configuration Item) team.

Available CI teams and their trigger conditions:
- PI Plan: Always included (program planning)
- Firmware: AT commands, modem, carrier config, FOTA, CLI UART
- Hardware: Modem selection, SKU, BOM, IMEI, antenna, PCB
- Field Tools: Endpoint programming, mobile tools, configuration UI
- FW DevOps: Build system, CI/CD, firmware deployment
- GMS: Network management, provisioning, cloud/server side
- NetwAbstr: Network protocols, communication stack
- Operations: OTA, deployment, provisioning, network rollout
- PLM: Product definition, SKU planning, pricing
- Procurement: Modem sourcing, vendor management, BOM
- Regulatory: PTCRB, FCC, carrier certification, compliance
- System Design: Architecture, cross-team interfaces, system integration
- Manufacturing: IMEI writing, TAC tracking, production line changes
- Documentation: Installation manuals, user guides, compliance docs
- Test/QA: Test planning, test case development, carrier testing

For each affected team, provide a concise numbered list of work areas (not paragraphs).

Respond with ONLY a JSON array (no markdown, no explanation):
[
  {
    "ciTeam": "Firmware",
    "title": "SubSystem Requirement title for this team",
    "description": "For '[Product]' in Firmware:\\n\\n1. Work area one\\n2. Work area two\\n3. Work area three"
  }
]`;

export interface SubSystemReqResult {
  workItemId: number;
  ciTeam: string;
  title: string;
}

export async function generateSubSystemRequirements(
  ado: AdoClient,
  systemReqId: number,
): Promise<SubSystemReqResult[]> {
  // 1. Read the System Requirement
  const sysReq = await ado.getWorkItem(systemReqId);
  const sysTitle = sysReq.fields["System.Title"] as string;
  const sysDescription = sysReq.fields["System.Description"] as string;
  const iterationPath = sysReq.fields["System.IterationPath"] as string;

  // 2. Try to read the parent MRS for extra context
  let mrsContext = "";
  const parentRelation = sysReq.relations?.find(
    (r) => r.rel === "System.LinkTypes.Hierarchy-Reverse",
  );
  if (parentRelation) {
    const mrsIdMatch = parentRelation.url.match(/\/(\d+)$/);
    if (mrsIdMatch) {
      const mrs = await ado.getWorkItem(parseInt(mrsIdMatch[1]));
      mrsContext = `\n\nParent MRS:\nTitle: ${mrs.fields["System.Title"]}\nDescription: ${mrs.fields["System.Description"]}`;
    }
  }

  // 3. Call AI
  const userMessage = `Identify affected CI teams and generate SubSystem Requirements for:\n\nSystem Requirement: ${sysTitle}\n\nDescription:\n${sysDescription}${mrsContext}`;
  const raw = await callModel(SYSTEM_PROMPT, userMessage);

  // Parse JSON array from response
  const jsonMatch = raw.match(/\[[\s\S]*\]/);
  if (!jsonMatch) throw new Error("AI did not return valid JSON array");
  const items = JSON.parse(jsonMatch[0]) as Array<{
    ciTeam: string;
    title: string;
    description: string;
  }>;

  // 4. Create SubSystem Requirements in ADO
  const results: SubSystemReqResult[] = [];
  const links: string[] = [];

  for (const item of items) {
    const areaPath = CI_TEAM_AREA_PATHS[item.ciTeam] || `ItronGlobalReqs`;

    const created = await ado.createWorkItem({
      type: "SubSystem Requirement",
      title: item.title,
      description: item.description,
      areaPath,
      iterationPath,
      parentId: systemReqId,
      tags: "AI-Draft",
      state: "New",
    });

    results.push({
      workItemId: created.id,
      ciTeam: item.ciTeam,
      title: item.title,
    });
    links.push(
      `• <a href="https://dev.azure.com/canayorachu/ItronGlobalReqs/_workitems/edit/${created.id}">#${created.id}</a> ${item.ciTeam} — ${item.title}`,
    );

    console.log(`Created SubSystem Requirement #${created.id}: ${item.ciTeam} — ${item.title}`);
  }

  // 5. Comment on the System Requirement
  await ado.addComment(
    systemReqId,
    `✅ Created ${results.length} SubSystem Requirements:<br><br>${links.join("<br>")}<br><br>Each is tagged AI-Draft. Review and label "Done" to trigger Feature/Story generation.`,
  );

  return results;
}
