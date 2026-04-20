/**
 * Entry point for pipeline-driven automation.
 *
 * Usage:
 *   node dist/index.js --work-item-id <id> --event-type <label-done|comment>
 *
 * Environment:
 *   SYSTEM_ACCESSTOKEN or ADO_TOKEN — ADO auth
 *   GITHUB_TOKEN or AZURE_OPENAI_ENDPOINT — AI model auth
 *   ADO_ORG (default: canayorachu)
 *   ADO_PROJECT (default: ItronGlobalReqs)
 */

import { AdoClient } from "./ado-client.js";
import { generateSystemRequirement } from "./generators/mrs-to-system-req.js";
import { generateSubSystemRequirements } from "./generators/sysreq-to-subsystem.js";
import { generateFeaturesAndStories } from "./generators/subsystem-to-features.js";

// Work item type reference names → friendly names
const TYPE_MAP: Record<string, string> = {
  "ItronRequirementsProcess.Requirement": "Requirement",
  "ItronRequirementsProcess.SystemRequirement": "System Requirement",
  "ItronRequirementsProcess.SubSystemRequirement": "SubSystem Requirement",
  // Standard types
  "Microsoft.VSTS.WorkItemTypes.Feature": "Feature",
  "Microsoft.VSTS.WorkItemTypes.UserStory": "User Story",
};

function parseArgs(): { workItemId: number; eventType: string } {
  const args = process.argv.slice(2);
  let workItemId = 0;
  let eventType = "label-done";

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--work-item-id" && args[i + 1]) {
      workItemId = parseInt(args[i + 1]);
      i++;
    } else if (args[i] === "--event-type" && args[i + 1]) {
      eventType = args[i + 1];
      i++;
    }
  }

  if (!workItemId) {
    console.error("Usage: node dist/index.js --work-item-id <id> [--event-type label-done|comment]");
    process.exit(1);
  }

  return { workItemId, eventType };
}

async function main(): Promise<void> {
  const { workItemId, eventType } = parseArgs();

  const org = process.env.ADO_ORG || "canayorachu";
  const project = process.env.ADO_PROJECT || "ItronGlobalReqs";
  const token = process.env.SYSTEM_ACCESSTOKEN || process.env.ADO_TOKEN || "";

  if (!token) {
    console.error("No ADO token found. Set SYSTEM_ACCESSTOKEN or ADO_TOKEN.");
    process.exit(1);
  }

  const ado = new AdoClient(org, project, token);

  if (eventType === "label-done") {
    await handleLabelDone(ado, workItemId);
  } else if (eventType === "comment") {
    await handleComment(ado, workItemId);
  } else {
    console.error(`Unknown event type: ${eventType}`);
    process.exit(1);
  }
}

async function handleLabelDone(ado: AdoClient, workItemId: number): Promise<void> {
  // Read the work item to determine its type
  const item = await ado.getWorkItem(workItemId);
  const witType = item.fields["System.WorkItemType"] as string;
  const resolvedType = TYPE_MAP[witType] || witType;

  console.log(`Processing "Done" label on ${resolvedType} #${workItemId}`);

  switch (resolvedType) {
    case "Requirement": {
      // MRS → System Requirement
      const result = await generateSystemRequirement(ado, workItemId);
      console.log(`✅ Created System Requirement #${result.workItemId}`);
      break;
    }
    case "System Requirement": {
      // System Requirement → SubSystem Requirements
      const results = await generateSubSystemRequirements(ado, workItemId);
      console.log(`✅ Created ${results.length} SubSystem Requirements`);
      break;
    }
    case "SubSystem Requirement": {
      // SubSystem Requirement → Features + User Stories
      const results = await generateFeaturesAndStories(ado, workItemId);
      const totalStories = results.reduce((sum, f) => sum + f.storyIds.length, 0);
      console.log(`✅ Created ${results.length} Features and ${totalStories} User Stories`);
      break;
    }
    case "Feature": {
      console.log("Feature labeled Done — end of pipeline. Ready for sprint planning.");
      break;
    }
    default: {
      console.log(`No automation configured for type: ${resolvedType}`);
    }
  }
}

async function handleComment(ado: AdoClient, workItemId: number): Promise<void> {
  // Future: parse @ai comments and execute instructions
  console.log(`Comment handling for #${workItemId} — not yet implemented`);
  // This would:
  // 1. Read the latest comment
  // 2. Check if it starts with @ai
  // 3. Parse the instruction
  // 4. Call AI to update the work item description
  // 5. Post a response comment with the diff
}

main().catch((err) => {
  console.error("Pipeline automation failed:", err);
  process.exit(1);
});
