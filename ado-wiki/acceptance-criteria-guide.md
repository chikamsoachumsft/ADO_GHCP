# Acceptance Criteria Writing Guide

> **Purpose**: Ensure acceptance criteria are precise enough for both human developers and AI code generation (GitHub Copilot coding agent) to implement correctly.

---

## Format: Given/When/Then (Gherkin Syntax)

```gherkin
Given [a precondition or context]
When [an action or event occurs]
Then [the expected outcome]
And [additional outcome]
```

Each story should have **3-7 acceptance criteria** covering:
1. **Happy path** (the main successful flow)
2. **Validation/error** (what happens with bad input)
3. **Edge case** (boundary conditions, empty states)
4. **Security** (if the story involves sensitive data or actions)

---

## The 5 Questions Every AC Must Answer

| # | Question | Example Answer |
|---|----------|---------------|
| 1 | What does success look like? | "Transfer completes and both balances update within 3 seconds" |
| 2 | What does failure look like? | "Insufficient funds shows inline error: 'Available balance is $X'" |
| 3 | What are the boundaries? | "Transfer amount: min $0.01, max $2,500 per transaction" |
| 4 | What must be logged/audited? | "All transfers logged with: timestamp, amount, from/to, customer ID" |
| 5 | What happens at the edges? | "If the last transfer hits the daily limit, show remaining daily allowance" |

---

## Examples by Feature Type

### API Endpoint

```gherkin
Given an authenticated customer with valid JWT
When they GET /api/accounts
Then the response returns 200 with all active accounts
And each account includes: id, type, nickname, availableBalance, ledgerBalance, status
And response time is < 500ms (P95)

Given an expired or invalid JWT
When they GET /api/accounts
Then the response returns 401 with body: { "error": "Unauthorized" }
And no account data is returned

Given a customer with no accounts (edge case)
When they GET /api/accounts
Then the response returns 200 with an empty array []
```

### Form Submission

```gherkin
Given the transfer form
When the customer enters amount = $0.00
Then the form shows inline validation: "Amount must be at least $0.01"
And the submit button remains disabled

Given the transfer form with valid data
When the customer clicks "Submit"
Then the button shows a loading spinner and is disabled (prevent double-submit)
And the transfer API is called exactly once
```

### Notification Trigger

```gherkin
Given a customer with email notifications enabled
When they complete a transfer > $1,000
Then a mandatory email is sent within 60 seconds containing:
  - Subject: "Large transfer alert — $[amount]"
  - Body: from/to accounts, amount, timestamp, confirmation number
  - Footer: "You cannot unsubscribe from security notifications"

Given a customer with email notifications DISABLED
When they complete a transfer > $1,000
Then the mandatory email is STILL sent (cannot opt out of security notifications)
And an in-app notification is also created
```

---

## Anti-Patterns to Avoid

| ❌ Bad AC | Why It's Bad | ✅ Better AC |
|-----------|-------------|-------------|
| "Should handle errors gracefully" | What does "gracefully" mean? | "Given an API timeout, When the transfer fails, Then show: 'Transfer could not be completed. Please try again.' and log the error with correlation ID" |
| "Must be fast" | How fast? | "API response < 500ms at P95 under 10K concurrent users" |
| "Data is validated" | Which fields? What rules? | "Email: valid RFC 5322 format. Phone: 10 digits, US format. Amount: numeric, 2 decimal places, > 0" |
| "User is notified" | How? When? What channel? | "Within 60 seconds, customer receives email + in-app notification with [specific content]" |
| "Looks like the mockup" | Mockups change; behavior doesn't | "Account card shows: nickname, last 4 digits, balance, status badge. Tap opens transaction details." |
| "Works on mobile" | Too vague | "On viewports < 768px: cards stack vertically, table switches to card layout, touch targets ≥ 44px" |

---

## Checklist Before Marking AC as Complete

- [ ] Each AC has exactly ONE Given/When/Then (don't bundle multiple behaviors)
- [ ] No subjective words: "appropriate", "reasonable", "user-friendly", "modern"
- [ ] Specific values: amounts, time limits, character counts, pixel sizes
- [ ] Error messages are written out (the actual text the user sees)
- [ ] Security scenarios included (unauthorized access, expired session)
- [ ] Performance targets stated (response time, page load)
- [ ] AC is testable: a QA engineer could write an automated test from it

---

## Linking AC to GitHub Copilot Coding Agent

When work items flow to GitHub Copilot coding agent, the AC becomes the **specification**. The more precise the AC:

- **Precise AC** → Copilot generates implementation matching the spec
- **Vague AC** → Copilot guesses, and the guesses may not match your intent

**Tip**: If you can't write an automated test from the AC, Copilot can't write the code either. Rewrite the AC until it's testable.
