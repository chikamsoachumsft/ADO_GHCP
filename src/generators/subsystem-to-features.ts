/**
 * Generator: SubSystem Requirement → Features + User Stories
 *
 * Reads a SubSystem Requirement, calls AI to generate implementation
 * and verification features with cross-multiplied user stories,
 * creates them in ADO, and comments on the parent.
 */

import { AdoClient } from "../ado-client.js";
import { callModel } from "../model-client.js";

const SYSTEM_PROMPT = `You are a senior TPM at Itron. You break down SubSystem Requirements into Features and User Stories.

For each SubSystem Requirement, create:
1. Implementation Feature(s) — building/coding the changes
2. Verification Feature(s) — testing/verifying the changes

For user stories, CROSS-MULTIPLY the relevant dimensions:
- Device models (e.g., 500G, 500W, 500S)
- Carriers (e.g., AT&T, Verizon, Rogers)
- Operations (e.g., Mobile Program, Network Program, Check Endpoint)

Naming conventions:
- Implementation: "[Team] - [Product] - [Operation] changes to include [Feature] - [Carrier]"
- Verification: "[Team] - [Product] - Verify [Operation] changes to include [Feature] - [Carrier]"

Respond with ONLY a JSON object (no markdown, no explanation):
{
  "features": [
    {
      "title": "Feature title",
      "description": "Feature description",
      "type": "implementation" | "verification",
      "stories": [
        {
          "title": "User Story title",
          "description": "Story description with acceptance criteria"
        }
      ]
    }
  ]
}`;

export interface FeatureResult {
  featureId: number;
  title: string;
  type: string;
  storyIds: number[];
}

export async function generateFeaturesAndStories(
  ado: AdoClient,
  subSystemReqId: number,
): Promise<FeatureResult[]> {
  // 1. Read the SubSystem Requirement
  const subSysReq = await ado.getWorkItem(subSystemReqId);
  const subSysTitle = subSysReq.fields["System.Title"] as string;
  const subSysDescription = subSysReq.fields["System.Description"] as string;
  const areaPath = subSysReq.fields["System.AreaPath"] as string;
  const iterationPath = subSysReq.fields["System.IterationPath"] as string;

  // 2. Read parent System Requirement for context
  let parentContext = "";
  const parentRelation = subSysReq.relations?.find(
    (r) => r.rel === "System.LinkTypes.Hierarchy-Reverse",
  );
  if (parentRelation) {
    const parentIdMatch = parentRelation.url.match(/\/(\d+)$/);
    if (parentIdMatch) {
      const parent = await ado.getWorkItem(parseInt(parentIdMatch[1]));
      parentContext = `\n\nParent System Requirement:\nTitle: ${parent.fields["System.Title"]}\nDescription: ${parent.fields["System.Description"]}`;
    }
  }

  // 3. Call AI
  const userMessage = `Generate Features and User Stories for:\n\nSubSystem Requirement: ${subSysTitle}\n\nDescription:\n${subSysDescription}${parentContext}`;
  const raw = await callModel(SYSTEM_PROMPT, userMessage);

  // Parse JSON from response
  const jsonMatch = raw.match(/\{[\s\S]*\}/);
  if (!jsonMatch) throw new Error("AI did not return valid JSON");
  const result = JSON.parse(jsonMatch[0]) as {
    features: Array<{
      title: string;
      description: string;
      type: string;
      stories: Array<{ title: string; description: string }>;
    }>;
  };

  // 4. Create Features and Stories in ADO
  const featureResults: FeatureResult[] = [];
  const featureLinks: string[] = [];
  let totalStories = 0;

  for (const feature of result.features) {
    // Create Feature
    const createdFeature = await ado.createWorkItem({
      type: "Feature",
      title: feature.title,
      description: feature.description,
      areaPath,
      iterationPath,
      parentId: subSystemReqId,
      tags: `AI-Draft; ${feature.type}`,
      state: "New",
    });

    const storyIds: number[] = [];

    // Create User Stories under this Feature
    for (const story of feature.stories) {
      const createdStory = await ado.createWorkItem({
        type: "User Story",
        title: story.title,
        description: story.description,
        areaPath,
        iterationPath,
        parentId: createdFeature.id,
        tags: "AI-Draft",
        state: "New",
      });
      storyIds.push(createdStory.id);
      totalStories++;
    }

    featureResults.push({
      featureId: createdFeature.id,
      title: feature.title,
      type: feature.type,
      storyIds,
    });

    featureLinks.push(
      `• <a href="https://dev.azure.com/canayorachu/ItronGlobalReqs/_workitems/edit/${createdFeature.id}">#${createdFeature.id}</a> [${feature.type}] ${feature.title} (${storyIds.length} stories)`,
    );

    console.log(`Created Feature #${createdFeature.id}: ${feature.title} with ${storyIds.length} stories`);
  }

  // 5. Comment on the SubSystem Requirement
  await ado.addComment(
    subSystemReqId,
    `✅ Created ${featureResults.length} Features and ${totalStories} User Stories:<br><br>${featureLinks.join("<br>")}<br><br>All tagged AI-Draft. Ready for sprint planning after review.`,
  );

  return featureResults;
}
