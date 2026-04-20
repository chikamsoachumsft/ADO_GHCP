# Demo Script: Itron AI-Powered Requirement Analysis Pipeline

**Duration:** ~30 minutes | **Audience:** Itron engineering leadership  
**Format:** Live VS Code demo with ADO boards walk-through

---

## Pre-Demo Checklist

- [ ] VS Code open with `ADO_GHCP` workspace
- [ ] ADO MCP server connected (test: `@plm-assistant` ping in Copilot Chat)
- [ ] ADO Boards open: `https://dev.azure.com/canayorachu/ItronGlobalReqs/_boards`
- [ ] ADO Wiki open: `https://dev.azure.com/canayorachu/ItronGlobalReqs/_wiki`
- [ ] Copilot Chat panel open in **Agent Mode** (not Ask or Edit)
- [ ] File open: `Itron_Requirement_Analysis_Process.md` (reference during intro)
- [ ] File open: `.github/agents/` folder visible in Explorer

---

## ACT 1: The Problem — Why This Matters (3 min)

### Show the document: `Itron_Requirement_Analysis_Process.md`

> "This document is from your own team — Srinivas wrote it. It lays out the 6-step process every requirement goes through at Itron."

Walk through the **6 steps** briefly:

1. PLM writes the MRS
2. Systems Engineer decomposes it into System Requirements
3. Systems Engineer fans out SubSystem Requirements to CI teams
4. TPM/PL refines the SubSystem Requirements
5. TPM/PL creates Features and User Stories
6. Team picks up work for implementation

**Key quote from the document:**

> "Our main objective is to integrate AI solution/workflow in **steps 3 and 5** where there is a lot of manual effort."

**Then say:**

> "That's exactly what we've built. But we didn't stop at steps 3 and 5 — we covered the **entire chain**, from MRS creation all the way down to sprint-ready user stories. And we did it with **five specialized AI agents** that each mirror a real role in your organization."

---

## ACT 2: The Agent Architecture — Five Roles, One Pipeline (5 min)

### Open `.github/agents/` in VS Code Explorer — show all 5 files

> "Each of these markdown files **is** an agent. Your team writes the instructions, Copilot follows them. No code, no deployment — just markdown in your repo."

Draw the pipeline on a whiteboard or show this diagram:

```
┌──────────────┐    ┌──────────────────┐    ┌──────────────────────┐
│ PLM          │───▶│ Systems Engineer │───▶│ TPM / Project Lead   │
│ Assistant    │    │                  │    │                      │
│              │    │ Job 1: MRS →     │    │ SubSystem Req →      │
│ Drafts MRS   │    │   System Req     │    │   Features +         │
│ in ADO       │    │                  │    │   User Stories        │
│              │    │ Job 2: SysReq →  │    │   (cross-multiplied) │
│              │    │   SubSystem Reqs │    │                      │
│              │    │   (per CI team)  │    │                      │
└──────────────┘    └──────────────────┘    └──────────────────────┘
       ▲                                              │
       │         ┌──────────────────┐                 │
       │         │ Itron Product    │                 │
       └─────────│ Knowledge       │─────────────────┘
                 │ (shared context) │
                 └──────────────────┘
                          ▲
                          │
                 ┌──────────────────┐
                 │ Requirements     │
                 │ Analyst          │
                 │ (gap analysis,   │
                 │  effort est.)    │
                 └──────────────────┘
```

### Walk through each agent's role and highlight the human-AI boundary:

| Step | Who Does What | Agent File |
|------|--------------|------------|
| 1. MRS Draft | **Human** decides what product to build. **AI** structures it into a complete MRS with all required sections. | `plm-assistant.md` |
| 2. System Req | **Human** reviews/approves. **AI** expands MRS into all 12 technical dimensions (carrier, HW, FW, regulatory, ops...). | `systems-engineer.md` |
| 3. SubSystem Reqs | **Human** confirms CI team list. **AI** identifies affected CI teams from a 15-team decision matrix and creates one SubSystem Req per team. | `systems-engineer.md` (Job 2) |
| 4-5. Features + Stories | **Human** reviews the breakdown. **AI** cross-multiplies dimensions (devices × carriers × operations) to produce the full story matrix. | `tpm.md` |
| Cross-cutting | **AI** looks up Itron product specs, carrier bands, and terminology from live documentation before generating anything. | `itron-product-knowledge.md` |

> "The critical insight here: **Humans make decisions. AI does the paperwork.** The PLM decides which carrier to support. The AI figures out that means touching Firmware, Hardware, Field Tools, Regulatory, Manufacturing, Documentation, and 9 other teams — and writes all 15 SubSystem Requirements in seconds instead of days."

---

## ACT 3: Deep Dive — Inside the Agent Files (8 min)

### 3A: The PLM Assistant (`plm-assistant.md`)

Open the file. Scroll to the **MRS Template** section (around line 23).

> "This agent knows the exact template every MRS must follow at Itron. When a PLM says 'I need AT&T CAT-M1 support on the GenX 500S', the agent asks 3-5 clarifying questions — not 20 — and generates a full MRS with:"

Point out each required section:
- High Level Requirement
- Stakeholder / Benefit
- Carrier bands with UL/DL frequencies
- Regulatory requirements (PTCRB, FCC)
- Assumptions and Constraints

**Key callout — scroll to "Default ADO Configuration" (line 44):**

> "Notice: organization, project, work item types, area paths, iterations — it's all hard-coded to YOUR ADO instance. The agent doesn't ask 'what project?' — it knows it's `ItronGlobalReqs`. It knows the area paths: System-INS, Firmware, Hardware, Field Tools."

**Key callout — scroll to the bottom, "Quality Checks":**

> "Before finalizing, the agent runs this checklist. It verifies the MRS has a clear 'shall' statement, that all frequency bands include both UL and DL ranges, that regulatory requirements are explicit. This is your team's institutional quality bar, enforced automatically."

### 3B: The Systems Engineer (`systems-engineer.md`)

Open the file. Scroll to the **CI Team Decision Matrix** (around line 77).

> "This is the high-value automation Srinivas identified in step 3. When the Systems Engineer approves a System Requirement, the agent reads it and decides which CI teams are affected."

Point at the table:

```
| CI Team       | Trigger Keywords                                    |
|---------------|-----------------------------------------------------|
| Firmware      | AT commands, modem, carrier config, FOTA, CLI UART  |
| Hardware      | Modem selection, SKU, BOM, IMEI, antenna, PCB       |
| Regulatory    | PTCRB, FCC, carrier certification, compliance       |
| Field Tools   | Endpoint programming, mobile tools, configuration   |
| Manufacturing | IMEI writing, TAC tracking, production line changes |
```

> "If a requirement mentions 'modem selection' and 'PTCRB certification', the agent automatically knows Hardware, Regulatory, Firmware, Procurement, Manufacturing, and Documentation are all affected. It creates a SubSystem Requirement for each team with a numbered list of their specific work areas."

**Key callout — scroll to "Structure for SubSystem Requirement Description":**

> "The output isn't paragraphs — it's numbered work areas. This is what your TPMs actually need: a concise scope list they can turn into features. The agent learned this from how your team already writes SubSystem Requirements in ADO."

### 3C: The TPM Agent (`tpm.md`)

Open the file. Scroll to the **Cross-Multiplication** section (around line 80).

> "This is the combinatorial explosion that eats your TPMs' time. Look at this example — 2 operations × 2 device models × 2 carriers = 8 implementation stories + their verification counterparts. The agent generates the full matrix automatically."

Read a few generated story titles aloud:

```
Field Tools - Gen 5 Cellular 500G - Mobile Program changes to include Carrier Configuration - AT&T
Field Tools - Gen 5 Cellular 500G - Mobile Program changes to include Carrier Configuration - Verizon
Field Tools - Gen 5 Cellular 500W - Mobile Program changes to include Carrier Configuration - AT&T
...
```

> "These aren't generic placeholders. Every story names the exact device model, the exact operation, and the exact carrier. That's because the agent reads the SubSystem Requirement and identifies the dimensions to cross-multiply."

**Key callout — the two feature types:**

> "Notice: every SubSystem Requirement produces BOTH an implementation feature and a verification feature. Your team already does this — the agent just automates the pattern."

### 3D: The Product Knowledge Base (`itron-product-knowledge.md`)

Open the file. Scroll through the sections.

> "This is the shared brain across all agents. It contains:"

Point to each section:
- **Product Taxonomy** — GenX 500S/500G/500W, Gen 5, OpenWay CENTRON
- **Glossary** — FOTA, TAC, PTCRB, CI, PCOMP, IEOS
- **Carrier & Band Reference** — AT&T Band 2/4/12, Verizon Band 4/13
- **Documentation URLs** — docs.itrontotal.com deep links

> "When any agent needs to know what 'GenX Cellular 500S' is, or what bands AT&T uses, it reads this file. And here's the important part — scroll to the bottom..."

Scroll to "How Agents Should Use This":

> "The agents don't just use static data. They can **fetch live documentation** from docs.itrontotal.com using Jina Reader. If a System Requirement mentions a product the agent hasn't seen before, it pulls the docs in real-time."

---

## ACT 4: Live Demo — The Full Pipeline in Action (10 min)

### Step 1: Draft an MRS with the PLM Assistant

Open Copilot Chat in Agent Mode. Type:

```
@plm-assistant We need to add T-Mobile CAT-M1 carrier support 
for the GenX Cellular 500S. This is for US deployments. 
Target: 2026 Q3.
```

**While it's working, narrate:**

> "Watch what happens. The agent will ask a few clarifying questions — which bands, any constraints on firmware, is this a new SKU or added to existing. Then it'll generate the full MRS."

**When it generates the MRS draft, point out:**
- The carrier band details (T-Mobile Band 2, Band 4, Band 71 with frequencies)
- Regulatory section (PTCRB, FCC, T-Mobile certification)
- Assumptions section (populated from domain knowledge)
- Hardware/Firmware/Ops implications

> "A PLM would spend a day writing this. The agent did it in 30 seconds — and it caught things like TAC requirements and T-Mobile's specific certification process that a new PLM might miss."

**Tell the agent to push it:**

```
Looks good. Create it in ADO under area path System-INS\Cellular, 
iteration 2026 Q3. Label it AI-Review.
```

> "It's now creating a `Requirement` work item in ADO — that's your custom MRS type. Let's see it in Boards."

**Switch to ADO Boards and show the new work item.**

### Step 2: Decompose with the Systems Engineer

```
@systems-engineer Read Requirement #[ID from step 1] and generate 
a System Requirement. Then decompose it into SubSystem Requirements 
for all affected CI teams.
```

**While it's working, narrate:**

> "The Systems Engineer agent is doing two jobs back-to-back. First: expand the MRS into a detailed System Requirement covering all 12 technical dimensions. Second: identify which of the 15 CI teams are affected and create a SubSystem Requirement for each."

**When the CI team plan appears, point out:**

> "Look — it identified Firmware, Hardware, Field Tools, Regulatory, Operations, Manufacturing, Procurement, Documentation, Test/QA, PI Plan, and System Design. Each with a specific scope. The agent shows you this plan **before** creating anything — you approve or modify."

**After approval:**

> "It just created 11 work items in ADO — all linked as children of the System Requirement, each with the correct area path for the CI team. A Systems Engineer would spend 2-3 days doing this manually."

### Step 3: Break Down with the TPM

Pick one of the SubSystem Requirements (e.g., Field Tools):

```
@tpm Read SubSystem Requirement #[Field Tools ID] and generate 
Features and User Stories. Cross-multiply across device models 
and operations.
```

**When the matrix appears:**

> "The TPM agent identified 3 device models (500S, 500G, 500W), 2 operations (Mobile Program, Network Program), and the T-Mobile carrier — that's 6 implementation stories and 6 verification stories across 2 features. Each story has a proper description and is ready for sprint planning."

**After it creates in ADO:**

> "Switch to Boards — you can now see the full hierarchy: MRS → System Requirement → SubSystem Requirement → Features → User Stories. Every link is set. Every area path is correct."

---

## ACT 5: The Automation Layer — Pipelines & Webhooks (3 min)

### Open `pipelines/label-transition.yml`

> "What if you don't want to type agent commands? We built an automation layer. When a work item gets labeled 'Done' in ADO, a Service Hook triggers this pipeline."

Point to the key section:

```yaml
webhooks:
  - webhook: ItronLabelDone
    connection: ItronLabelDone
```

> "The pipeline reads the work item type and runs the correct generator automatically:"

Open `src/index.ts` and point to the switch statement:

```typescript
switch (resolvedType) {
  case "Requirement":
    // MRS → System Requirement
    await generateSystemRequirement(ado, workItemId);
    break;
  case "System Requirement":
    // System Requirement → SubSystem Requirements
    await generateSubSystemRequirements(ado, workItemId);
    break;
  case "SubSystem Requirement":
    // SubSystem Requirement → Features + User Stories
    await generateFeaturesAndStories(ado, workItemId);
    break;
}
```

> "So the flow becomes: PLM writes an MRS → labels it 'Done' → System Requirement appears automatically → Systems Engineer reviews, refines, labels 'Done' → SubSystem Requirements appear → TPM reviews, refines, labels 'Done' → Features and Stories appear. Each step has a **human review gate**. Nothing cascades without approval."

### Open `pipelines/comment-handler.yml`

> "And for mid-flight iteration: anyone can post a comment starting with `@ai` on any work item, and the pipeline picks it up and applies the instruction. 'Add a test scenario for offline mode' — done. 'Split story 3 into AT&T and Verizon' — done."

---

## ACT 6: The Backend — How Data Flows Through the System (2 min)

### Quick walk of the `src/` directory

> "This is the TypeScript backend that powers the pipeline automation. Three layers:"

| File | Role |
|------|------|
| `ado-client.ts` | REST client for Azure DevOps — reads/writes work items, posts comments, manages parent-child links |
| `model-client.ts` | AI model client — works with GitHub Models or Azure OpenAI, JSON extraction built in |
| `generators/mrs-to-system-req.ts` | MRS → System Requirement — calls AI with Itron-specific system prompt |
| `generators/sysreq-to-subsystem.ts` | System Req → SubSystem Reqs — includes the CI team decision matrix and area path mapping |
| `generators/subsystem-to-features.ts` | SubSystem Req → Features + Stories — cross-multiplication logic |

**Key callout — open `sysreq-to-subsystem.ts`, show the area path mapping:**

```typescript
const CI_TEAM_AREA_PATHS: Record<string, string> = {
  "Firmware": "ItronGlobalReqs\\Firmware",
  "Hardware": "ItronGlobalReqs\\Hardware",
  "Field Tools": "ItronGlobalReqs\\Itron Mobile Field Tool",
  // ... 15 teams mapped
};
```

> "Every CI team maps to the correct ADO area path. When SubSystem Requirements are created, they land in the right team's backlog automatically."

---

## ACT 7: The Human-AI Loop — What Makes This Different (2 min)

Draw or describe this loop:

```
  HUMAN                          AI
  ─────                          ──
  PLM has an idea        →   PLM Agent drafts full MRS
  PLM reviews/edits      →   Pushes to ADO
  SysEng labels "Done"   →   Pipeline creates System Req
  SysEng reviews         →   Labels "Done" when satisfied
  Pipeline fires         →   Creates 10-15 SubSystem Reqs
  TPM reviews each       →   Labels "Done" on their CI's req
  Pipeline fires         →   Creates Features + Stories
  Team plans sprint      →   Stories ready with full context
```

> "At every step, a human makes the decision. The AI does the expansion, the formatting, the cross-multiplication, the linking. This is important: **the AI doesn't decide what to build**. The PLM decides what to build. The AI figures out all the work that decision implies."

> "And this is bidirectional. If a TPM thinks a SubSystem Requirement is wrong, they comment on it. The @ai pipeline picks up the comment and refines. The human is always in the loop."

---

## ACT 8: Wrap-Up — Impact & What's Next (2 min)

### Quantify the before and after:

| Activity | Before (Manual) | After (AI-Assisted) |
|----------|-----------------|---------------------|
| Write MRS | 1-2 days | 5 minutes |
| MRS → System Requirement | 1 day | 2 minutes |
| System Requirement → SubSystem Reqs (10+ teams) | 2-3 days | 1 minute |
| SubSystem Req → Features + Stories | 1-2 days per team | 2 minutes per team |
| **Total: MRS to sprint-ready stories** | **2-3 weeks** | **Under 30 minutes** |

### What the team saw Srinivas wanted (from the process doc):

> "Srinivas identified three additional use cases in his conclusion:"

1. **Cascade changes** — when a requirement changes, propagate the update down through the whole chain
2. **Historical estimation** — use past data to estimate new features
3. **Traceability reports** — predictability, risk, throughput, quality insights

> "Use case 1 is what the `@ai` comment handler enables today. Use cases 2 and 3 are natural extensions — the agents already know the work item hierarchy, so querying it for traceability or estimation is straightforward."

### Handle Likely Questions:

**Q: "How do we customize this for our specific process?"**
> "Edit the markdown files in `.github/agents/`. Want to add a new CI team? Add a row to the table in `systems-engineer.md`. Want to change the story naming convention? Edit the pattern in `tpm.md`. Your team owns the instructions."

**Q: "What about product knowledge — do we need to maintain that file?"**
> "The `itron-product-knowledge.md` file is the starting point, but the agents can also fetch live docs from docs.itrontotal.com. So it's low maintenance — update it when new product families launch."

**Q: "Does this work with our custom work item types?"**
> "Yes — notice in the code, we map `ItronRequirementsProcess.Requirement`, `SystemRequirement`, and `SubSystemRequirement`. Those are your custom types. The agents create work items using your custom types, not generic Epics/Features."

**Q: "What if the AI generates something wrong?"**
> "Every output is a draft labeled `AI-Review`. Nothing goes to sprint without human review. And the @ai comment handler lets you iterate: 'remove the Operations SubSystem Requirement, not needed for this product.' The AI applies the change and posts a diff."

**Q: "Can different CI teams customize their agent behavior?"**
> "Absolutely. The TPM agent is one file, but you could create `tpm-firmware.md`, `tpm-field-tools.md` with team-specific story templates, naming conventions, and acceptance criteria patterns."

---

## Emergency Recovery Plays

| Problem | Recovery |
|---------|----------|
| MCP not connected | Show the agent files and walk through what would happen. "The agent would call ADO MCP to read this work item and create children." |
| AI takes too long | Show pre-created work items in ADO. "Here's what the output looks like — created earlier by the same agents." |
| Wrong work item IDs | Have a list of known IDs ready: MRS, System Req, SubSystem Req, Feature |
| Agent gives unexpected output | "This is a draft — the human reviews it. Let me show you the correct output from an earlier run." |
| ADO permissions error | Switch to showing the `src/generators/*.ts` code and explain data flow |
