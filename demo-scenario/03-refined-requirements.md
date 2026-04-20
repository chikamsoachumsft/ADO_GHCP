# Refined Requirements — Customer Self-Service Portal

> **Source**: AI-refined from `01-project-brief.md` + gap analysis from `02-ai-gap-analysis.md`  
> **Status**: DRAFT — Assumptions marked with ⚠️ need stakeholder validation  
> **Wiki Context Used**: Domain Glossary, Architecture Context, Requirements Standards

---

## 1. Authentication & Authorization

### REQ-AUTH-01: Multi-Factor Authentication
Customers must authenticate using email/password plus a second factor (SMS OTP or authenticator app). Biometric login (Face ID/Touch ID) should be supported on mobile devices.

- ⚠️ **Assumption**: MFA is mandatory for all logins, not just sensitive operations
- Session timeout: 15 minutes of inactivity
- Re-authentication required for: fund transfers > $500, profile changes, adding new payees

### REQ-AUTH-02: Role-Based Access
- **Primary account holder**: Full access
- **Joint account holder**: Full access (same as primary)
- **Authorized user**: View-only access unless explicitly granted transfer rights
- **Power of Attorney**: Configurable by back-office, not self-service
- ⚠️ **Assumption**: Joint accounts exist in the core banking system

### REQ-AUTH-03: Session Security
- JWT-based sessions with 15-minute sliding expiration
- Concurrent session limit: 3 devices max
- Force logout capability from profile page
- All sessions invalidated on password change

---

## 2. Account Dashboard

### REQ-DASH-01: Account Overview
Display all customer accounts with:
- Account nickname, last 4 digits of account number, account type
- Current balance (available and ledger)
- Account status (active, frozen, closed)

**Account types in scope**: Checking, Savings, Money Market, CD
- ⚠️ **Assumption**: Loans, credit cards, and investment accounts are Phase 2

### REQ-DASH-02: Transaction History
- Default view: Last 30 days
- Searchable/filterable: up to 18 months
- Export: CSV and PDF
- Search by: date range, amount range, description keyword, transaction type
- Pending transactions shown separately with "Pending" badge

---

## 3. Fund Transfers

### REQ-XFER-01: Internal Transfers (Own Accounts)
- Real-time between customer's own Contoso accounts
- No daily limit for internal transfers
- Immediate balance reflection

### REQ-XFER-02: Internal Transfers (Other Contoso Customers)
- Recipient identified by: account number + routing number, OR saved payee
- Daily limit: $5,000 (configurable by account type)
- Per-transaction limit: $2,500
- ⚠️ **Assumption**: Limits are system defaults; back-office can override per customer
- Processing: Real-time during business hours (6 AM – 9 PM ET), next business day otherwise
- Re-authentication required for transfers > $500

### REQ-XFER-03: Payee Management
- Save, edit, delete payees
- New payee requires: name, account number, routing number
- 24-hour hold on first transfer to new payee (fraud prevention)
- ⚠️ **Assumption**: External (ACH/wire) transfers are Phase 2

### REQ-XFER-04: Transfer Cancellation
- Pending transfers can be cancelled before processing
- Processed transfers cannot be self-service cancelled — customer directed to support

---

## 4. Bill Pay

### REQ-BILL-01: Bill Payment Setup
- Add biller by: search from biller directory OR manual entry (name, address, account number)
- Payment types: one-time, recurring (weekly, bi-weekly, monthly, quarterly)
- Schedule payments up to 365 days in advance
- Minimum payment: $1.00

### REQ-BILL-02: Recurring Payment Management
- Edit amount, frequency, next payment date
- Pause recurring payments (with resume date)
- Cancel recurring payments
- Email reminder 3 days before scheduled payment

### REQ-BILL-03: Payment Processing
- Cut-off time: 4 PM ET for same-day processing
- Processing time: 1-3 business days (electronic), 5-7 business days (check)
- ⚠️ **Assumption**: Integration with existing bill pay processor (not building from scratch)

---

## 5. Support Tickets

### REQ-SUPP-01: Ticket Submission
- Categories: Account inquiry, Transaction dispute, Technical issue, Document request, Other
- Required fields: category, subject, description
- Optional: attachment (max 3 files, 10 MB each, PDF/JPG/PNG)
- Auto-generated ticket number displayed on submission

### REQ-SUPP-02: Ticket Tracking
- Status values: Submitted, In Review, Awaiting Customer, Resolved, Closed
- Customer can add comments to open tickets
- Customer can reopen resolved tickets within 7 days
- SLA display: expected response time by category

---

## 6. Document Upload

### REQ-DOC-01: Upload Capability
- Allowed formats: PDF, JPG, PNG, TIFF
- Max file size: 25 MB per file, 100 MB total per request
- Virus scanning on upload (block infected files)
- Client-side file type validation + server-side verification

### REQ-DOC-02: Document Requests
- Back-office creates document requests visible in customer portal
- Request shows: document type needed, reason, deadline
- Customer uploads against specific request (linked)
- Status: Requested → Uploaded → Under Review → Accepted/Rejected
- ⚠️ **Assumption**: Document review is manual (back-office), not AI-automated in Phase 1

### REQ-DOC-03: Document Retention
- Uploaded documents retained for 7 years per regulatory requirements
- Customer can view (but not delete) previously uploaded documents
- ⚠️ **Assumption**: 7-year retention based on GLBA/SOX; legal team to confirm

---

## 7. Notifications

### REQ-NOTIF-01: Notification Channels
- **Email**: All notification types
- **SMS**: Security alerts, large transaction alerts (opt-in)
- **Push notifications**: Mobile app (opt-in)
- **In-app**: All notification types (always on, not opt-out-able)

### REQ-NOTIF-02: Mandatory Notifications (Cannot Opt Out)
- Login from new device
- Password change
- Failed login attempts (3+)
- Transfer > $1,000
- Account status change

### REQ-NOTIF-03: Optional Notifications (Customer Configurable)
- Transaction alerts (with customizable threshold)
- Low balance alerts (with customizable threshold)
- Bill payment reminders
- Document request reminders
- Support ticket updates

---

## 8. Profile Management

### REQ-PROF-01: Editable Fields
- Email address (re-verification required)
- Phone number (re-verification required via OTP)
- Mailing address
- Communication preferences
- Notification settings
- Display name / nickname

### REQ-PROF-02: Non-Editable Fields (Require Back-Office)
- Legal name
- SSN/TIN
- Date of birth
- Account ownership structure

---

## 9. Non-Functional Requirements

### REQ-NFR-01: Performance
- Page load: < 2 seconds (P95)
- API response: < 500ms (P95)
- Transaction processing: < 3 seconds end-to-end
- Concurrent users: 10,000 minimum

### REQ-NFR-02: Availability
- SLA: 99.9% uptime (excludes planned maintenance)
- Planned maintenance window: Sundays 2 AM – 6 AM ET
- Graceful degradation: read-only mode if core banking API is down

### REQ-NFR-03: Security Standards
- OWASP Top 10 compliance
- PCI-DSS Level 1 compliance (if handling card data)
- SOC 2 Type II audit readiness
- Annual penetration testing
- All data encrypted at rest (AES-256) and in transit (TLS 1.3)
- ⚠️ **Assumption**: PCI-DSS scope depends on whether credit card data is displayed

### REQ-NFR-04: Accessibility
- WCAG 2.1 AA compliance
- Screen reader compatible
- Keyboard navigation for all features
- Color contrast ratio ≥ 4.5:1

### REQ-NFR-05: Audit Logging
- All authentication events
- All financial transactions
- All profile changes
- All document uploads
- Log retention: 7 years
- Tamper-proof audit log (append-only)

---

## Phase Mapping

| Feature | Phase 1 (Q3 2026) | Phase 2 (Q4 2026) |
|---|---|---|
| Authentication (MFA) | ✅ | — |
| Account Dashboard | ✅ | — |
| Transaction History (18 mo) | ✅ | — |
| Internal Transfers (own) | ✅ | — |
| Internal Transfers (Contoso customers) | ✅ | — |
| External Transfers (ACH/Wire) | — | ✅ |
| Bill Pay | ✅ | — |
| Support Tickets | ✅ | — |
| Document Upload | ✅ | — |
| Notifications (Email + In-App) | ✅ | — |
| Notifications (SMS + Push) | — | ✅ |
| Profile Management | ✅ | — |
| Loans/Credit Card Views | — | ✅ |
| AI Document Verification | — | ✅ |
| Chatbot Support | — | ✅ |
