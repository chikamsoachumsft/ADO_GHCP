# Definition of Ready (DoR)

> **Purpose**: A user story must meet ALL criteria below before it can be pulled into a sprint. This ensures the team has enough information to estimate, develop, and test without needing to chase stakeholders mid-sprint.

---

## Checklist

### Story Quality
- [ ] **Title** is action-oriented and descriptive (5-10 words)
- [ ] **User story format** follows: As a [role], I want [action], So that [value]
- [ ] **Description** provides sufficient context for a developer who hasn't seen the original requirement
- [ ] **Acceptance criteria** use Given/When/Then format with specific values
- [ ] **Happy path** is covered in acceptance criteria
- [ ] **At least one error/edge case** is covered in acceptance criteria
- [ ] **Story points** are estimated by the team (not pre-assigned)

### Scope & Dependencies
- [ ] **Scope is clear**: what's in AND what's explicitly out
- [ ] **No unresolved dependencies** on other teams or stories
- [ ] **API contracts** are defined (if story involves backend integration)
- [ ] **Third-party dependencies** are confirmed available (if applicable)

### Design & UX
- [ ] **Mockup or wireframe** exists for any new UI (even sketch-level)
- [ ] **Empty states** are defined (what does the user see when there's no data?)
- [ ] **Loading states** are defined (skeleton, spinner, or placeholder)
- [ ] **Error states** are defined (what does the user see on failure?)
- [ ] **Responsive behavior** is specified (mobile vs desktop layout)

### Non-Functional
- [ ] **Performance target** is stated (if applicable)
- [ ] **Security requirement** is explicit (authentication, authorization, data protection)
- [ ] **Accessibility** requirements are stated (WCAG level, keyboard nav, screen reader)
- [ ] **Audit logging** needs are identified (what events must be logged?)

### Testing
- [ ] **Test approach** is clear (unit, integration, e2e, manual)
- [ ] **Test data requirements** are identified
- [ ] **Browser/device matrix** is defined (if UI)

---

## How to Use This Checklist

1. **Product Owner** drafts the story
2. **AI analysis** runs against the story to identify gaps (using the requirement analysis prompt)
3. **Team reviews** during backlog refinement — walking through this checklist
4. **If any box is unchecked**, the story goes back to refinement (not into sprint)

---

## Common Reasons Stories Are NOT Ready

| Issue | Resolution |
|-------|-----------|
| "The stakeholder said it should be intuitive" | Ask: "What does the user see on this screen? What can they click?" |
| No error scenarios | Ask: "What happens if [the network fails / the API returns an error / the user enters invalid data]?" |
| Missing performance targets | Default: < 2s page load, < 500ms API response |
| No accessibility mention | Default: WCAG 2.1 AA for all new pages |
| "Same as [other product]" | Document the exact behavior — don't reference external products |
| Story too large (> 13 SP) | Split into smaller stories that each deliver value independently |
