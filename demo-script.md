# Demo Script: AI-Driven Requirements Analysis & Work Item Management

**Duration:** ~25 minutes | **Format:** Live demo with pre-loaded context

---

## Pre-Demo Setup (do before the call)

- [ ] VS Code open with `ADO_GHCP` workspace
- [ ] ADO MCP server connected (check with a quick `@requirements-analyst` ping)
- [ ] `demo-slides.html` open in browser, ready to present
- [ ] ADO Boards open in a browser tab → `https://dev.azure.com/canayorachu/Contoso-SelfService-Portal/_boards`
- [ ] ADO Wiki open in another tab → `https://dev.azure.com/canayorachu/Contoso-SelfService-Portal/_wiki`
- [ ] GitHub repo open → `https://github.com/chikamsoachumsft/customer-banking-portal`
- [ ] `demo-scenario/01-project-brief.md` open in VS Code editor

---

## ACT 1: Set the Stage (Slides — 5 min)

### Slide 1 — Title
> "Today I want to show you how GitHub Copilot, combined with Azure DevOps via MCP, can transform the way your teams go from vague stakeholder requests to sprint-ready work items — and even to working code."

### Slide 2 — The Problem
> "Let's talk about why this matters. These aren't made-up numbers — industry research consistently shows that **60% of defects trace back to bad requirements**. Not bad code — bad *requirements*."

**Talking points:**
- "How much time does your team spend in refinement sessions clarifying stories?"
- "When was the last time a security gap was caught at planning vs. in code review?"
- "The cost multiplier is real — a bug caught in planning costs 1x, in dev it's 2-3x, in production it's 10-30x."

### Slide 3 — Mapping Toil to Agents
> "Here's the key idea: **every manual bottleneck in your SDLC has an agent that can eliminate it**. We're not replacing people — we're eliminating toil so your engineers focus on problem-solving, not paperwork."

**Talking points:**
- Point to each card briefly — requirements, context, code gen, compliance
- "Notice the pattern: the old way is manual, sequential, and error-prone. The new way is AI-assisted, parallel, and standards-enforced."
- "The glue that makes this work is **MCP** — Model Context Protocol. It lets Copilot talk directly to Azure DevOps, read your wiki, create work items — all without leaving the IDE."

### Slide 4 — End-to-End Flow
> "Here's the 5-step flow we're about to demo live. A vague brief goes in, and at the other end, you get structured work items in ADO and even a PR with working code."

**Key callout:**
- "Steps 2-4 happen in one agent conversation. The agent reads the brief, pulls your team's wiki for context, identifies gaps, creates work items, and estimates effort — all in one shot."

### Slide 5 — Demo Agenda
> "Let me show you this for real. Everything after step 1 is live — no pre-recorded, no mock data."

---

## ACT 2: Show the Vague Brief (1 min)

**Switch to VS Code** — show `demo-scenario/01-project-brief.md`

> "This is what a real stakeholder brief looks like. A product manager sends this over — it says 'we want a self-service banking portal' with 7 bullet points. No acceptance criteria, no security requirements, no performance targets, no accessibility considerations."

**Talking points:**
- Scroll through it quickly — let them see how thin it is
- "This is what every dev team starts with. And right now, a BA or PM would spend 2-3 weeks turning this into proper stories."
- "Let's see what happens when we hand this to an AI agent."

---

## ACT 3: Run the Requirements Analyst Agent (8-10 min)

**Open Copilot Chat in Agent Mode** → Type:

```
@requirements-analyst Analyze the project brief in demo-scenario/01-project-brief.md. 
The ADO project is "Contoso-SelfService-Portal" in org "canayorachu". 
Pull context from the ADO Wiki under /Requirements-Context/. 
Focus on the "Profile Management" epic — identify gaps, create the epic with features 
and PBIs in ADO, and provide effort estimation. Use industry best practices to fill gaps.
```

### While the agent is working, narrate what's happening:

**Step 1 — Brief Reading:**
> "First, the agent reads the brief. It's parsing the natural language and identifying what's explicitly stated vs. what's missing."

**Step 2 — Wiki Context Pull (watch for MCP tool calls):**
> "Now watch — it's calling the ADO MCP server to pull wiki pages. This is your team's institutional knowledge: your architecture standards, domain glossary, definition of ready, acceptance criteria guidelines. The agent doesn't guess — it reads your team's actual standards."

**Talking point while waiting:**
- "This is a custom agent — it's a markdown file in your repo. Your team can customize the workflow, add steps, change the gap analysis categories. It's not a black box."
- "MCP is the key differentiator here. Without it, the AI would hallucinate your standards. With it, the AI reads your actual wiki and applies your rules."

**Step 3 — Gap Analysis:**
> "Here's the gap analysis. The agent found gaps the brief didn't address — things like password complexity requirements, session timeout policies, MFA, WCAG accessibility, data encryption at rest. These are the things that normally get discovered in sprint 3 when a security review happens."

**Key talking points:**
- Point out severity levels (Critical, High, Medium)
- "Every gap has a recommended default. The agent isn't just saying 'this is missing' — it's saying 'here's what the industry standard is, and here's what I recommend.'"
- "A junior BA would miss half of these. A senior BA would catch them but spend a week. This took seconds."

**Step 4 — Work Item Creation (watch for MCP tool calls to ADO):**
> "Now the agent is creating work items directly in Azure Boards. Watch the MCP calls — it's creating an Epic, then Features underneath it, then Product Backlog Items under each Feature."

**When it finishes, switch to ADO Boards tab and refresh:**
> "Let's go see what it created in ADO."

**In ADO Boards, show:**
- The new Epic for Profile Management
- Expand to show Features (e.g., Profile Viewing, Profile Editing, Security Settings)
- Click into one PBI — show the acceptance criteria (Given/When/Then format)
- Show story points assigned
- "Every PBI follows your team's Definition of Ready. Given/When/Then acceptance criteria with specific values — not 'user can update profile' but 'Given a logged-in user, When they update their display name to a value between 2-50 characters, Then the change is persisted and a confirmation toast appears within 2 seconds.'"

**Step 5 — Effort Estimation:**
> "Finally, the agent provides effort estimation. This isn't just story points — it's a 3-point estimate with optimistic, most likely, and pessimistic scenarios, complexity multipliers, risk factors, and a suggested sprint roadmap."

**Talking points:**
- "This gives your PM real data for capacity planning — not gut feels from a planning poker session."
- "The estimates account for your team's velocity parameters and include risk buffers."

---

## ACT 4: Show the Pre-Loaded Work Items (2 min)

> "Now let me show you the full picture. Before this call, I had the same agent process the other 7 epics from the brief. Let me show you what a fully analyzed backlog looks like."

**In ADO Boards, show:**
- 8 Epics total (7 pre-loaded + 1 just created live)
- Expand one pre-loaded epic to show the hierarchy: Epic → Features → PBIs
- "That's 8 epics, 24 features, and approximately 65 PBIs — all with acceptance criteria, story points, and proper hierarchy. Created from a one-page brief."

**Talking point:**
> "How long would this take your BA team manually? Two weeks? Three? This took under 10 minutes total."

---

## ACT 5: Show the Wiki Context (2 min)

**Switch to ADO Wiki tab:**
> "Let me show you what the agent was reading when it made those decisions."

**Show each wiki page briefly:**
1. **Domain Glossary** — "The agent knows what 'ACH' means, what 'Reg D' is, what T+1 settlement means"
2. **Architecture Context** — "It knows you're building React + .NET, so it creates PBIs appropriate for that stack"
3. **Requirements Standards** — "It knows your team uses Given/When/Then and INVEST principles"
4. **Definition of Ready** — "Every PBI it creates passes your DoR checklist"
5. **Acceptance Criteria Guide** — "It follows your team's AC writing standards"

> "The power here is that **this is YOUR knowledge, not generic AI output**. When your team updates the wiki, the agent automatically follows the new standards next time. No retraining needed."

---

## ACT 6: Copilot Coding Agent (3 min)

> "Now here's where it gets really exciting. Those PBIs we just created? We can assign them to the Copilot coding agent and it will write the code."

**Option A — Show a completed PR (pre-done):**
- Switch to GitHub repo → Pull Requests tab
- Show the PR that the coding agent already created for the Login issue
- Show the code changes, tests, and how it followed the copilot-instructions

**Option B — Trigger live (if time permits):**
- Create a GitHub issue from one of the PBIs
- Assign to Copilot
- "This will run in the background and open a PR — usually takes 5-10 minutes"

> "The coding agent also uses MCP to pull context from your ADO Wiki. So it knows your coding conventions, your architecture patterns, your API structure — it's not just generating generic boilerplate."

---

## ACT 7: Wrap-Up & Key Takeaways (2 min)

> "Let me recap what we just saw:"

1. **A vague brief → 65+ structured work items** in under 10 minutes
2. **AI gap analysis** caught security, compliance, and accessibility gaps that would normally surface weeks later
3. **Your team's wiki IS the AI's brain** — MCP connects Copilot to your institutional knowledge
4. **Custom agents are just markdown files** — your team owns and customizes the workflow
5. **End-to-end automation** — from requirements to deployed code, with humans approving at each gate

> "This isn't replacing your BAs or your developers. It's giving them superpowers. Your BA reviews and refines the AI output instead of writing from scratch. Your devs review PRs instead of writing boilerplate."

### Handle Common Questions:

**Q: "Is the AI hallucinating requirements?"**
> "That's why the wiki context is critical. The agent reads your actual standards, not generic training data. And every output is a work item your team reviews — nothing deploys without human approval."

**Q: "What about sensitive data / compliance?"**
> "MCP connections stay within your Azure DevOps org. The ADO PAT controls access scope. No data leaves your org boundary — GitHub Copilot processes the context but doesn't store your work items."

**Q: "How hard is this to set up?"**
> "The agent is a markdown file. The MCP server is an npm package. The wiki pages are templates you customize once. A team can be up and running in a day."

**Q: "Can we customize the agent's behavior?"**
> "Absolutely — the agent instructions are in `.github/agents/requirements-analyst.md`. Want to add a step for regulatory compliance? Edit the markdown. Want to change the gap analysis categories? Edit the markdown. Your team owns it entirely."

**Q: "Does this work with our existing ADO setup?"**
> "Yes — MCP works with any ADO org. It reads your existing wikis, creates work items in your existing boards, follows your existing process template (Scrum, Agile, or CMMI)."

---

## Emergency Recovery Plays

| Problem | Recovery |
|---------|----------|
| MCP server won't connect | Show the pre-loaded work items: "Let me show you the output from when I ran this earlier" |
| Agent takes too long | Narrate the gap analysis from `demo-scenario/02-ai-gap-analysis.md` and show pre-loaded items |
| ADO is slow/down | Show screenshots or the GitHub repo's agent file and explain the flow conceptually |
| Question derails the flow | "Great question — let me park that and come back to it after the demo" |
