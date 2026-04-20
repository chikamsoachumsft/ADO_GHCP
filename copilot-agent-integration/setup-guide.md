# GitHub Copilot Coding Agent — ADO Integration Setup

> **Purpose**: Connect Azure DevOps work items to GitHub Copilot coding agent so that AI-refined user stories with precise acceptance criteria automatically trigger code generation.

---

## Architecture

```
ADO Work Item (User Story)             GitHub Repository
┌──────────────────────┐               ┌──────────────────────┐
│ Title                │               │                      │
│ Description          │   ──trigger──▶│  GitHub Issue         │
│ Acceptance Criteria  │               │  (synced from ADO)    │
│ Story Points         │               │                      │
│ Tags                 │               │       │               │
└──────────────────────┘               │       ▼               │
                                       │  Copilot Coding Agent │
                                       │       │               │
                                       │       ▼               │
                                       │  Pull Request         │
                                       │  (generated code)     │
                                       └──────────────────────┘
```

---

## Prerequisites

1. **GitHub Repository** linked to your ADO project
2. **GitHub Copilot Business/Enterprise** with coding agent enabled
3. **Azure Boards ↔ GitHub** integration configured
4. A `.github/copilot-instructions.md` file in the repo (see below)

---

## Step 1: Link ADO Project to GitHub

```
ADO Project Settings → Boards → GitHub connections → Add connection
```

- Authenticate with GitHub OAuth
- Select the target repository
- This syncs ADO work items ↔ GitHub Issues via AB# links

---

## Step 2: Configure the Copilot Coding Agent

In your GitHub repository, create `.github/copilot-instructions.md`:

```markdown
# Copilot Coding Agent Instructions

## Project Context
This is the Contoso Financial Customer Self-Service Portal.
- Stack: React 18 + TypeScript (frontend), .NET 8 C# (backend)
- UI Library: Fluent UI React v9
- State Management: React Query (TanStack Query)
- Testing: xUnit (backend), Vitest + Testing Library (frontend)

## Code Standards
- Follow existing patterns in the codebase
- All API endpoints require `[Authorize]` attribute
- Use DTOs for API request/response (never expose domain models)
- All financial amounts use `decimal` type (never `float` or `double`)
- Include unit tests for all new code (minimum 80% coverage)

## Acceptance Criteria
The acceptance criteria in the linked issue/work item are the specification.
Implement EXACTLY what the acceptance criteria describe — no more, no less.

## Security Rules
- Validate all input server-side (even if client validates)
- Use parameterized queries (never string concatenation for SQL)
- Sanitize all user-generated content displayed in UI
- Log security events to audit trail (use IAuditLogger)

## File Organization
- Backend: `src/API/Controllers/`, `src/API/Services/`, `src/API/Models/`
- Frontend: `src/web/src/pages/`, `src/web/src/components/`, `src/web/src/hooks/`
- Tests: `tests/API.Tests/`, `src/web/src/__tests__/`
```

---

## Step 3: Trigger Copilot Coding Agent from ADO

### Option A: Automatic via AB# Link (Recommended)

1. When an ADO work item moves to **"Ready for Development"** state:
   - The ADO → GitHub sync creates a GitHub Issue
   - The issue body contains the user story + acceptance criteria

2. Assign the GitHub Issue to `copilot` (the coding agent user)

3. Copilot coding agent:
   - Reads the issue (your AC becomes the spec)
   - Analyzes the codebase
   - Creates a branch
   - Implements the code
   - Opens a PR with tests

### Option B: Manual via GitHub Issue

1. Create a GitHub Issue directly with the ADO work item content:

```markdown
## User Story
As a customer, I want to transfer money between my own accounts
so that I can manage my funds.

## Acceptance Criteria
Given a customer with 2+ accounts
When they select source and destination accounts and enter an amount
Then the transfer processes in real-time
And both account balances update immediately

Given a transfer amount exceeding available balance
When submitted
Then an error states 'Insufficient funds' and the transfer is blocked

## Technical Notes
- Backend endpoint: POST /api/transfers/internal
- Use TransferService.CreateInternalTransfer()
- Log to audit trail via IAuditLogger

## ADO Link
AB#12345
```

2. Assign to `copilot`

### Option C: Automated Pipeline Trigger

Create an ADO pipeline that auto-creates GitHub Issues when work items move to "Ready":

```yaml
# azure-pipelines.yml (triggered by work item state change via service hook)
trigger: none

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: PowerShell@2
    displayName: 'Create GitHub Issue from ADO Work Item'
    inputs:
      targetType: 'inline'
      script: |
        $workItemId = "$(System.WorkItemId)"
        # Fetch work item details from ADO API
        # Create GitHub Issue via GitHub API
        # Assign to 'copilot' user
        # Link back to ADO via AB# tag
    env:
      GITHUB_TOKEN: $(GitHubToken)
      ADO_PAT: $(AdoPat)
```

---

## Step 4: Review the Generated PR

When Copilot coding agent creates a PR:

1. **Check the implementation matches the AC** — each Given/When/Then should be implemented
2. **Review tests** — Copilot should have generated tests matching the AC scenarios
3. **Run CI pipeline** — build, test, lint, security scan
4. **Link PR back to ADO** — Add `AB#[work-item-id]` in the PR description to auto-link

---

## Step 5: Close the Loop

```
ADO Work Item ──→ GitHub Issue ──→ Copilot PR ──→ Review ──→ Merge
     │                                                         │
     └──── State: "Ready" ──────────────────→ State: "Done" ◄──┘
                    (auto-transition via AB# link)
```

- When the PR is merged, the linked ADO work item auto-transitions to "Done"
- Full traceability: requirement → gap analysis → refined AC → generated code → tested → deployed
