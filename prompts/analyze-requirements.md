# Prompt: Analyze Requirements for Gaps and Ambiguities

> **Usage**: Feed this prompt + the raw requirements document to an AI assistant (GitHub Copilot Chat, GPT-4, etc.) to identify gaps, ambiguities, and missing requirements.

---

## Prompt Template

```
You are a senior business analyst and requirements engineer specializing in 
financial services applications. You have deep knowledge of banking regulations 
(GLBA, SOX, PCI-DSS, ADA), security best practices (OWASP), and software 
engineering standards.

## Your Task
Analyze the following project requirements and produce a gap analysis report.

## Context Documents (from ADO Wiki)
- Domain Glossary: [paste or reference the domain glossary]
- Architecture Context: [paste or reference architecture constraints]
- Requirements Standards: [paste or reference the writing standards]
- Definition of Ready checklist: [paste or reference the DoR]

## Requirements to Analyze
[PASTE THE RAW REQUIREMENTS HERE]

## Analysis Instructions

1. **Identify Gaps**: Find requirements that are missing entirely.
   Categorize as: Security, Compliance, Performance, Accessibility, 
   Data/Privacy, Error Handling, Edge Cases, Integration, UX.

2. **Identify Ambiguities**: Find statements that could be interpreted 
   multiple ways. List each interpretation option.

3. **Risk Assessment**: Rate each gap as CRITICAL / HIGH / MEDIUM / LOW 
   based on impact to project success and regulatory compliance.

4. **Generate Questions**: For each gap, write the specific question to 
   ask the stakeholder to resolve it.

5. **Suggest Defaults**: Where industry standards exist (e.g., WCAG 2.1 AA 
   for accessibility, 15-min session timeout for banking), suggest defaults 
   that can be used if the stakeholder doesn't override.

## Output Format
Use the following structure:
- Summary (total gaps found, risk distribution)
- Critical Gaps (table: #, Gap, Risk, Question for Stakeholder)
- Important Gaps (table: same format)
- Minor Gaps (table: same format)
- Ambiguities (table: Statement, Ambiguity, Interpretation Options)
- Recommendations (prioritized action items)
```

---

## Tips for Best Results

1. **Include the Wiki context docs** — the richer the context, the more specific the gap analysis
2. **Run against individual features** if the full brief is too large
3. **Iterate**: Fix the gaps identified, then re-run the analysis on the refined version
4. **Compare against DoR**: Use the Definition of Ready checklist as a validation pass
