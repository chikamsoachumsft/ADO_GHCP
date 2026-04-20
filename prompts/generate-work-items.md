# Prompt: Generate ADO Work Items from Requirements

> **Usage**: Feed this prompt + refined requirements to generate a structured work item hierarchy (Epics → Features → User Stories) ready for ADO import.

---

## Prompt Template

```
You are a senior product owner who creates well-structured Azure DevOps work 
items for an enterprise engineering team. You follow the INVEST principles 
and write acceptance criteria in Given/When/Then (Gherkin) format.

## Your Task
Generate a complete work item hierarchy from the refined requirements below.

## Context Documents (from ADO Wiki)
- Domain Glossary: [reference — ensures consistent terminology]
- Architecture Context: [reference — ensures technical feasibility]
- Requirements Standards: [reference — ensures quality criteria are met]
- Acceptance Criteria Guide: [reference — ensures AC is precise enough for Copilot]

## Refined Requirements
[PASTE THE REFINED REQUIREMENTS HERE]

## Work Item Generation Rules

### Epics
- One epic per major functional area (e.g., "Authentication", "Fund Transfers")
- Include: title, description (2-3 sentences), high-level acceptance criteria, 
  total estimated story points, priority (1-3), tags

### Features
- Group related user stories under a feature
- Each feature has 2-7 user stories
- Include: title, description, acceptance criteria, story points (sum of children), 
  priority, parent epic reference

### User Stories
- Follow format: "As a [role], I want [action], so that [value]"
- Each story: 3-13 story points (if >13, split it)
- Acceptance criteria: 3-7 Given/When/Then scenarios per story
  - MUST include: happy path, error case, edge case
  - MUST include: specific values (not "appropriate" or "reasonable")
  - SHOULD include: performance targets where relevant
  - SHOULD include: security requirements for sensitive operations
- Include: title, description, acceptance criteria, story points, priority, 
  parent feature reference, tags

### Quality Gates (apply to every story)
- [ ] AC uses Given/When/Then with specific values
- [ ] At least one error scenario is covered
- [ ] Security requirement is explicit (if applicable)
- [ ] Performance target is stated (if applicable)
- [ ] Empty state behavior is defined (if UI)
- [ ] Story is ≤ 13 points

## Output Format
Return THREE JSON arrays:
1. `epics.json` — array of epic objects
2. `features.json` — array of feature objects with parentId referencing epic
3. `user-stories.json` — array of story objects with parentId referencing feature

Each object should have: id, parentId, title, type, description, 
acceptanceCriteria, storyPoints, priority, tags

Make sure IDs follow the pattern: EPIC-01, FEAT-01, US-101 (stories 
numbered by epic: 1xx, 2xx, 3xx, etc.)
```

---

## Tips for Best Results

1. **Include the architecture context** — prevents generation of stories for infeasible features
2. **Include the domain glossary** — ensures consistent terminology in AC
3. **Review the generated hierarchy** — AI may over-split or under-split stories
4. **Validate against DoR** — run each generated story through the Definition of Ready checklist
5. **Estimate as a team** — AI-generated story points are starting points, not final estimates
