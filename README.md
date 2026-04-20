# AI-Driven Requirement Analysis & Work Item Management — ADO Demo

## Demo Scenario

**Project**: Contoso Financial — Customer Self-Service Portal  
**Use Case #1**: AI-driven requirement analysis and work item management  
**Tools**: GitHub Copilot Agent Mode + Azure DevOps MCP Server + ADO Boards/Wiki → GitHub Copilot Coding Agent

---

## What This Demo Shows

| Capability | How We Show It |
|---|---|
| **Identify requirement gaps and ambiguities** | Custom Copilot agent reads a vague brief, cross-references wiki context, surfaces 23 gaps live |
| **Support requirement clarifications and effort estimation** | Agent refines requirements interactively, estimates T-shirt sizes with risk assessment |
| **Automatically draft work items** | Agent creates Epics → Features → User Stories directly in ADO via MCP tools |
| **Context-driven quality** | Agent reads ADO Wiki (glossary, architecture, DoR) to produce domain-aware work items |
| **Code generation trigger** | ADO work items (with AI-written specs) trigger GitHub Copilot coding agent via AB# links |

---

## How It Works

```
┌────────────────────────────┐
│  VS Code — Agent Mode      │
│                            │
│  @requirements-analyst     │  ← Custom Copilot agent
│      │                     │
│      ├─ reads ado-wiki/*   │  ← Domain glossary, architecture, DoR, AC guide
│      ├─ reads brief        │  ← Raw stakeholder requirements
│      │                     │
│      ├─ ADO MCP Server ──────→ Creates wiki pages in ADO
│      └─ ADO MCP Server ──────→ Creates work items (Epics/Features/Stories)
│                            │
└────────────────────────────┘
         │
         ▼
┌────────────────────────────┐
│  ADO Boards                │
│  ├─ Epics → Features       │
│  │   → User Stories (AC)   │──→ GitHub Issue (AB# link)
│  └─ Wiki (context pages)   │        │
└────────────────────────────┘        ▼
                              ┌──────────────────┐
                              │ Copilot Coding   │
                              │ Agent → PR       │
                              └──────────────────┘
```

---

## Demo Flow (30-minute walkthrough)

### Act 1 — "The Messy Handoff" (5 min)
1. Show the raw stakeholder brief (`demo-scenario/01-project-brief.md`)
2. Point out it's typical: high-level, missing edge cases, no NFRs

### Act 2 — "AI Finds the Gaps" (10 min) — LIVE with Agent
3. Switch to **Agent Mode** in Copilot Chat
4. Select the **@requirements-analyst** agent
5. Prompt: `Analyze the requirements in demo-scenario/01-project-brief.md`
6. Agent reads the brief + wiki context, produces gap analysis live
7. Walk through the gaps interactively — ask the agent to clarify specific ones

### Act 3 — "From Requirements to Work Items" (10 min) — LIVE with Agent
8. Prompt: `Create the work items in ADO project "Contoso-SelfService"`
9. Agent uses ADO MCP tools to create Epics, Features, User Stories directly in ADO
10. Open ADO Boards — show the backlog populated in real-time
11. Prompt: `Create wiki pages for the domain glossary and architecture context`
12. Agent pushes context docs to ADO Wiki

### Act 4 — "From Work Item to Working Code" (5 min)
13. Pick a user story with clear acceptance criteria
14. Show how it triggers GitHub Copilot coding agent
15. Show the generated PR with code matching the acceptance criteria

---

## Project Structure

```
ADO_GHCP/
├── .vscode/
│   └── mcp.json                           ← MCP server config (@azure-devops/mcp)
├── .github/
│   ├── copilot-instructions.md            ← Global Copilot instructions
│   └── agents/
│       └── requirements-analyst.md        ← Custom agent mode (the star of the demo)
├── demo-scenario/
│   ├── 01-project-brief.md                ← Raw stakeholder requirements (intentionally vague)
│   ├── 02-ai-gap-analysis.md              ← Reference gap analysis (fallback if live demo fails)
│   ├── 03-refined-requirements.md         ← Reference refined requirements
│   └── 04-effort-estimation.md            ← Reference effort estimation
├── ado-work-items/
│   ├── work-item-hierarchy.md             ← Visual hierarchy of epics/features/stories
│   ├── create-work-items.ps1              ← Fallback script (REST API) if MCP tools unavailable
│   └── sample-items/
│       ├── epics.json                     ← Epic definitions
│       ├── features.json                  ← Feature definitions
│       └── user-stories.json              ← User stories with acceptance criteria
├── ado-wiki/
│   ├── requirements-standards.md          ← Standards for writing requirements (agent context)
│   ├── domain-glossary.md                 ← Domain terms — reduces ambiguity (agent context)
│   ├── architecture-context.md            ← Technical constraints (agent context)
│   ├── definition-of-ready.md             ← DoR checklist (agent context)
│   └── acceptance-criteria-guide.md       ← How to write testable AC (agent context)
├── copilot-agent-integration/
│   ├── setup-guide.md                     ← Connect ADO work items → GH Copilot coding agent
│   └── sample-workflow.md                 ← End-to-end: work item → code → PR
└── prompts/
    ├── analyze-requirements.md            ← Prompt template: gap analysis
    ├── generate-work-items.md             ← Prompt template: work item generation
    └── estimate-effort.md                 ← Prompt template: effort estimation
```

---

## Prerequisites

- **VS Code** with GitHub Copilot extension
- **Node.js 20+** (for the MCP server)
- Azure DevOps organization with a project
- GitHub repository linked to the ADO project (for Copilot coding agent in Act 4)

## Quick Start — Agent Demo (Recommended)

```
1. Open this workspace in VS Code
2. The MCP server config (.vscode/mcp.json) auto-loads — click "Start" when prompted
3. Open Copilot Chat → switch to Agent Mode
4. Select the @requirements-analyst agent
5. Prompt: "Analyze the requirements in demo-scenario/01-project-brief.md"
6. The agent does the rest — reading context, finding gaps, creating work items in ADO
```

## Fallback — Script-Based

If MCP tools aren't available during the demo, use the PowerShell script:

```powershell
$env:ADO_ORG = "https://dev.azure.com/your-org"
$env:ADO_PROJECT = "Contoso-SelfService"
$env:ADO_PAT = "your-pat-here"

.\ado-work-items\create-work-items.ps1          # creates 69 work items
.\ado-work-items\create-work-items.ps1 -DryRun   # preview mode
```
