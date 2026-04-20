# Requirements Writing Standards

> **Purpose**: Provide a consistent standard for writing requirements so that AI-assisted analysis and code generation produce high-quality results. This page lives in the ADO Wiki and is referenced by team members and AI tools.

---

## The INVEST Checklist for User Stories

Every user story must be:

| Letter | Meaning | Test |
|--------|---------|------|
| **I** | Independent | Can be developed and deployed without depending on another story |
| **N** | Negotiable | Details can be discussed; it's not a contract |
| **V** | Valuable | Delivers value to the end user or business |
| **E** | Estimable | Team can estimate the effort with reasonable confidence |
| **S** | Small | Fits within a single sprint |
| **T** | Testable | Has clear pass/fail acceptance criteria |

---

## User Story Template

```
Title: [Action-oriented title, 5-10 words]

As a [role],
I want to [action/capability],
So that [business value/outcome].

Acceptance Criteria:
Given [context/precondition]
When [action/trigger]
Then [expected outcome]

Given [another scenario]
When [action/trigger]  
Then [expected outcome]

Non-Functional Requirements:
- Performance: [specific target, e.g., < 2s response time]
- Security: [specific requirement, e.g., requires MFA]
- Accessibility: [specific standard, e.g., WCAG 2.1 AA]

Out of Scope:
- [Explicitly list what this story does NOT cover]

Dependencies:
- [Other stories or systems this depends on]

Test Notes:
- [Edge cases to test]
- [Browser/device requirements]
```

---

## Acceptance Criteria Rules

### DO
- Use **Given/When/Then** format (Gherkin syntax)
- Include **happy path** AND at least one **error/edge case**
- State **specific values** (not "appropriate", "timely", "reasonable")
- Include **performance targets** where relevant
- Include **security requirements** for sensitive operations
- Cover **empty states** (what does the user see when there's no data?)

### DON'T
- Don't use vague language: "should work well", "user-friendly", "modern"
- Don't assume shared understanding: define exact behavior
- Don't skip error scenarios
- Don't reference other stories without explicit links
- Don't mix multiple features in one story

---

## Bad vs Good Examples

### ❌ Bad
> "The login page should be secure and user-friendly"

### ✅ Good
> **Given** a registered customer  
> **When** they enter valid email and password  
> **Then** they are prompted for MFA (SMS OTP or Authenticator)  
> **And** the login form does not reveal whether the email or password was incorrect  
> **And** the page loads within 2 seconds on 3G connections

---

## Requirement Categories Checklist

When writing requirements for any feature, ensure you've addressed:

- [ ] **Functional**: What does it do?
- [ ] **Security**: Authentication, authorization, data protection
- [ ] **Performance**: Response times, throughput, concurrent users
- [ ] **Accessibility**: WCAG compliance, keyboard navigation, screen readers
- [ ] **Error Handling**: What happens when things go wrong?
- [ ] **Edge Cases**: Empty states, max limits, concurrent modifications
- [ ] **Data**: Validation rules, retention, privacy
- [ ] **Audit**: What must be logged for compliance?
- [ ] **Integration**: External systems, APIs, data flow
- [ ] **Localization**: Languages, date formats, currencies (if applicable)

---

## Effort Estimation Guide

| T-Shirt | Story Points | Definition |
|---------|-------------|------------|
| XS | 1-2 | Config change, copy update, simple toggle |
| S | 3 | Single component, no API changes, no new data |
| M | 5 | New API endpoint + UI, standard CRUD |
| L | 8 | Multiple components, new data model, external integration |
| XL | 13 | Cross-cutting concern, significant complexity, new infrastructure |
| XXL | 21+ | **Too big — break it down** |
