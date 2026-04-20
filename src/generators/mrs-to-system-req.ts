/**
 * Generator: MRS (Requirement) → System Requirement
 *
 * Reads an MRS work item, calls AI to generate a detailed System Requirement,
 * creates it as a child in ADO, and comments on the parent.
 */

import { AdoClient, type WorkItem } from "../ado-client.js";
import { callModel } from "../model-client.js";

const SYSTEM_PROMPT = `You are a senior Systems Engineer at Itron. You decompose Marketing Requirement Specifications (MRS) into detailed System Requirements.

When given an MRS, generate a System Requirement that expands it into ALL applicable technical dimensions:

• Carrier/Network specifications (bands, frequencies, protocols)
• Hardware requirements (modem selection, SKUs, IMEI, BOM impacts)
• Firmware requirements (AT commands, carrier configuration, tunnelat, CLI UART)
• Regulatory requirements (PTCRB, FCC, carrier certification, prescan testing)
• Operations requirements (OTA process, modem provisioning, network deployment)
• Manufacturing requirements (IMEI writing, TAC tracking, modem ordering)
• Documentation requirements (installation manuals, compliance docs)
• Type Allocation Code (TAC) requirements (PTCRB thresholds, device limits)
• Firmware Over The Air (FOTA) requirements
• Single firmware image requirements (multi-carrier support)
• Procurement requirements (modem sourcing, part number changes)
• Test requirements (carrier-specific test cases, AT command port access)

Respond with ONLY a JSON object (no markdown, no explanation):
{
  "title": "System Requirement title",
  "description": "Full HTML description with all sections"
}`;

export interface SystemReqResult {
  workItemId: number;
  title: string;
}

export async function generateSystemRequirement(
  ado: AdoClient,
  mrsId: number,
): Promise<SystemReqResult> {
  // 1. Read the MRS
  const mrs = await ado.getWorkItem(mrsId);
  const mrsTitle = mrs.fields["System.Title"] as string;
  const mrsDescription = mrs.fields["System.Description"] as string;
  const mrsAreaPath = mrs.fields["System.AreaPath"] as string;
  const mrsIterationPath = mrs.fields["System.IterationPath"] as string;

  // 2. Call AI
  const userMessage = `Decompose this MRS into a System Requirement:\n\nTitle: ${mrsTitle}\n\nDescription:\n${mrsDescription}`;
  const raw = await callModel(SYSTEM_PROMPT, userMessage);

  // Parse JSON from response
  const jsonMatch = raw.match(/\{[\s\S]*\}/);
  if (!jsonMatch) throw new Error("AI did not return valid JSON");
  const result = JSON.parse(jsonMatch[0]) as { title: string; description: string };

  // 3. Create System Requirement in ADO
  const created = await ado.createWorkItem({
    type: "System Requirement",
    title: result.title,
    description: result.description,
    areaPath: mrsAreaPath,
    iterationPath: mrsIterationPath,
    parentId: mrsId,
    tags: "AI-Draft",
    state: "New",
  });

  // 4. Comment on the MRS
  await ado.addComment(
    mrsId,
    `✅ Created System Requirement <a href="https://dev.azure.com/canayorachu/ItronGlobalReqs/_workitems/edit/${created.id}">#${created.id}</a> — ${result.title}<br><br>Status: Draft — review and label "Done" to trigger SubSystem Requirement decomposition.`,
  );

  console.log(`Created System Requirement #${created.id}: ${result.title}`);
  return { workItemId: created.id, title: result.title };
}
