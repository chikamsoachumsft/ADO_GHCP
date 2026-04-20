# Prompt: Estimate Effort from Refined Requirements

> **Usage**: Feed this prompt + the refined requirements + work item hierarchy to generate effort estimates with risk assessment and timeline projections.

---

## Prompt Template

```
You are a senior engineering manager experienced in agile estimation for 
financial services applications. You use T-shirt sizing with story point 
mapping and account for complexity factors specific to regulated industries.

## Your Task
Estimate the effort for the work items below and produce a timeline projection.

## Context
- Team size: [NUMBER] engineers
- Sprint length: [NUMBER] weeks
- Expected velocity: [NUMBER] story points per sprint
- Technology stack: [LIST STACK]
- Key constraints: [LIST — e.g., "Core banking API has 100 req/sec limit"]

## Work Items to Estimate
[PASTE THE WORK ITEM HIERARCHY OR REFINED REQUIREMENTS]

## Estimation Instructions

### For Each Epic:
1. Assign a T-shirt size (S/M/L/XL) with story point range
2. List risk factors that could inflate the estimate
3. Note dependencies that affect sequencing

### For Each User Story:
1. Assign story points (Fibonacci: 1, 2, 3, 5, 8, 13)
2. Note complexity driver (e.g., "third-party integration", "security review")
3. Flag stories > 8 points for potential splitting

### Complexity Multipliers
Apply these multipliers for financial services:
- Security review required: +30% effort
- Regulatory compliance (audit logging, data retention): +20% effort
- Third-party integration (new): +50% effort
- Third-party integration (existing): +20% effort
- Accessibility (WCAG AA): +15% effort
- Performance optimization (< 500ms target): +10% effort

### Timeline Projection
1. Sequence epics by dependency and priority
2. Map to sprints (account for 80% capacity — 20% for bugs, meetings, etc.)
3. Provide three scenarios:
   - Optimistic (no blockers): X sprints at Y% confidence
   - Likely (normal friction): X sprints at Y% confidence
   - Pessimistic (major blockers): X sprints at Y% confidence

### Risk Assessment
For each epic, identify:
- Technical risks (what could go wrong technically)
- Dependency risks (what external teams/systems could block us)
- Scope risks (where is scope most likely to expand)

## Output Format
1. Summary table: Epic | T-Shirt | Story Points | Sprints | Risk Level
2. Detailed breakdown: Story-level estimates with complexity notes
3. Timeline: Sprint-by-sprint feature mapping
4. Risk matrix: Risk | Probability | Impact | Mitigation
5. Recommendation: MVP vs full scope if timeline is tight
```

---

## Tips for Best Results

1. **Provide real team velocity** — AI estimates are only useful with realistic velocity data
2. **Include architecture constraints** — the Core Banking API rate limit affects concurrency design effort
3. **Flag unknowns explicitly** — better to say "unknown, assuming medium" than guess
4. **Use as starting point** — team planning poker should validate/override AI estimates
5. **Re-estimate after sprint 2** — actual velocity data makes future estimates more accurate
