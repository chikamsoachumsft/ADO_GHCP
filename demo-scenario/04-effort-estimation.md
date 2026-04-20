# AI-Assisted Effort Estimation — Customer Self-Service Portal

> **Based on**: Refined requirements (`03-refined-requirements.md`)  
> **Method**: T-shirt sizing with story point mapping and historical velocity assumptions  
> **Assumptions**: Team of 5 engineers, 2-week sprints, velocity ~40 SP/sprint

---

## Estimation Summary

| Epic | T-Shirt | Story Points | Sprints | Risk |
|------|---------|-------------|---------|------|
| Authentication & Security | XL | 55 | 1.5 | HIGH — MFA + session mgmt + security review |
| Account Dashboard | M | 21 | 0.5 | LOW — Standard CRUD, API already exists |
| Fund Transfers | XL | 60 | 1.5 | HIGH — Financial logic, limits, fraud checks |
| Bill Pay | L | 34 | 1.0 | MEDIUM — Third-party integration |
| Support Tickets | M | 21 | 0.5 | LOW — Standard workflow |
| Document Upload | M | 26 | 0.7 | MEDIUM — Virus scanning, retention |
| Notifications | L | 34 | 1.0 | MEDIUM — Multi-channel, preference management |
| Profile Management | S | 13 | 0.3 | LOW — Standard forms |
| NFR / Cross-Cutting | L | 40 | 1.0 | HIGH — Performance, accessibility, audit |
| **TOTAL** | | **304 SP** | **~8 sprints** | |

---

## Detailed Breakdown by Feature

### Epic 1: Authentication & Security (55 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| Login page with email/password | 3 | Low | Standard form |
| MFA setup flow (SMS + Authenticator) | 8 | High | TOTP integration, SMS provider |
| MFA challenge on login | 5 | Medium | Token verification |
| Biometric login (mobile) | 8 | High | Platform-specific (Face ID, Touch ID) |
| Session management (timeout, concurrent limits) | 5 | Medium | JWT + Redis |
| Re-authentication for sensitive operations | 5 | Medium | Middleware pattern |
| Password reset flow | 5 | Medium | Email verification + MFA |
| Force logout (all devices) | 3 | Low | Invalidate all tokens |
| Security headers + OWASP hardening | 5 | Medium | CSP, HSTS, rate limiting |
| Login audit logging | 3 | Low | Append to audit log |
| Account lockout after failed attempts | 5 | Medium | Progressive delays + notification |

### Epic 2: Account Dashboard (21 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| Account list with balances | 5 | Medium | Core banking API integration |
| Transaction history (30-day default) | 5 | Medium | Pagination, sorting |
| Transaction search/filter (18 months) | 5 | Medium | Date, amount, keyword filters |
| Transaction export (CSV + PDF) | 3 | Low | Server-side generation |
| Pending transactions display | 3 | Low | Separate query + badge |

### Epic 3: Fund Transfers (60 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| Internal transfer (own accounts) | 8 | Medium | Balance validation, immediate |
| Transfer to Contoso customer (by account #) | 8 | High | Recipient validation |
| Transfer limits enforcement | 8 | High | Daily + per-tx, account type rules |
| Payee management (CRUD) | 5 | Medium | Save, edit, delete |
| New payee 24-hour hold | 5 | Medium | Fraud prevention logic |
| Transfer confirmation + receipt | 3 | Low | Summary screen + email |
| Transfer cancellation (pending) | 5 | Medium | Status check + reversal |
| Re-auth for transfers > $500 | 5 | Medium | Step-up authentication |
| Transfer history + search | 5 | Medium | Dedicated view with filters |
| Fraud velocity checks | 8 | High | Rate limiting + pattern detection |

### Epic 4: Bill Pay (34 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| Biller search + directory | 5 | Medium | Third-party biller DB |
| Manual biller entry | 3 | Low | Form validation |
| One-time payment | 5 | Medium | Scheduling + confirmation |
| Recurring payment setup | 8 | High | Frequency rules, next-date calc |
| Recurring payment management | 5 | Medium | Edit, pause, cancel |
| Payment reminders (3-day) | 3 | Low | Scheduled notification |
| Payment history | 5 | Medium | Status tracking |

### Epic 5: Support Tickets (21 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| Ticket submission form | 5 | Medium | Categories, attachments |
| Ticket list + status tracking | 5 | Medium | Filtering, pagination |
| Ticket detail + comment thread | 5 | Medium | Real-time updates |
| Ticket reopen (within 7 days) | 3 | Low | Status transition |
| SLA display | 3 | Low | Category-based lookup |

### Epic 6: Document Upload (26 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| File upload (drag & drop + browse) | 5 | Medium | Client-side validation |
| Virus scanning integration | 8 | High | ClamAV or cloud-based |
| Document request workflow | 5 | Medium | Back-office creates, customer fulfills |
| Document status tracking | 3 | Low | Status state machine |
| Document history (view uploaded) | 5 | Medium | 7-year retention, read-only |

### Epic 7: Notifications (34 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| Email notification service | 5 | Medium | Template engine + email provider |
| In-app notification center | 8 | High | Real-time, read/unread, bell icon |
| Mandatory notification triggers | 5 | Medium | Event-driven, non-configurable |
| Notification preferences UI | 8 | High | Per-category, per-channel matrix |
| Notification preference enforcement | 5 | Medium | Filter logic before send |
| Notification history | 3 | Low | Log of sent notifications |

### Epic 8: Profile Management (13 SP)

| Story | Points | Complexity | Notes |
|-------|--------|-----------|-------|
| View profile page | 3 | Low | Read from core banking |
| Edit contact info (with re-verification) | 5 | Medium | OTP for phone, email verification |
| Edit preferences/settings | 3 | Low | Simple form save |
| Change password | 2 | Low | Current + new + MFA |

---

## Timeline Projection

```
Sprint 1-2:  Authentication & Security (55 SP)         → Foundation, must be first
Sprint 3:    Account Dashboard (21 SP) + Profile (13 SP) → Quick wins after auth
Sprint 4-5:  Fund Transfers (60 SP)                     → Core feature, highest complexity
Sprint 5-6:  Bill Pay (34 SP)                           → Parallel-able with transfers
Sprint 6-7:  Notifications (34 SP) + Tickets (21 SP)    → Mid-complexity
Sprint 7-8:  Document Upload (26 SP) + NFR hardening    → Final features + polish
Sprint 8:    Integration testing, pen test, UAT          → Buffer sprint
```

**Estimated Phase 1 delivery: 8-9 sprints (16-18 weeks)**  
**Target**: Q3 2026 (July–September) = 12 weeks → **⚠️ Timeline is aggressive**

---

## Risk-Adjusted Recommendation

| Scenario | Sprints | Confidence |
|----------|---------|-----------|
| Optimistic (no blockers, API ready) | 7 | 20% |
| Likely (some API delays, 1 scope change) | 9 | 60% |
| Pessimistic (major API issues, scope creep) | 12 | 90% |

**Recommendation**: Negotiate Q3 for MVP (Auth + Dashboard + Transfers + Profile) and Q4 for remaining features. This de-risks the timeline while delivering core value early.
