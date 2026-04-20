# Domain Glossary — Contoso Financial

> **Purpose**: Eliminate ambiguity by defining domain terms precisely. Reference this glossary when writing requirements, reviewing code, or interpreting stakeholder requests. This glossary feeds into AI analysis to ensure consistent language.

---

## Account Types

| Term | Definition | Notes |
|------|-----------|-------|
| **Checking Account** | A transactional deposit account for daily banking (deposits, withdrawals, bill pay, transfers). | No transaction limits. |
| **Savings Account** | An interest-bearing deposit account with limited transactions per statement period. | Federal Reg D limit: 6 withdrawals/month (though suspended, Contoso still enforces 6/month). |
| **Money Market Account** | A higher-yield savings account requiring a minimum balance, with limited check-writing. | Minimum balance: $2,500. Below minimum incurs $15/month fee. |
| **Certificate of Deposit (CD)** | A time-deposit account with fixed term and interest rate. | Early withdrawal penalty: 90 days of interest. Cannot be used for transfers out. |

## Balance Types

| Term | Definition | Example |
|------|-----------|---------|
| **Available Balance** | Funds currently available for use (excludes holds and pending transactions). | Account has $5,000, $500 check deposited (day 0) → Available: $5,200 ($300 immediate credit). |
| **Ledger Balance** | The actual account balance including all posted transactions but excluding pending. | Same example → Ledger: $5,500. |
| **Pending Amount** | Sum of authorized but unposted transactions (debit card holds, pending transfers). | Card swipe at gas station for $1 hold → Pending: $1. |

## Transfer Types

| Term | Definition | Scope in Phase 1 |
|------|-----------|------------------|
| **Internal Transfer (Own)** | Moving funds between the customer's own accounts at Contoso. | ✅ In scope |
| **Internal Transfer (P2P)** | Sending funds to another Contoso customer by account number. | ✅ In scope |
| **ACH Transfer** | Automated Clearing House electronic transfer to/from external bank. | ❌ Phase 2 |
| **Wire Transfer** | Same-day electronic transfer via Fedwire, typically for large amounts. | ❌ Phase 2 |
| **Zelle** | Real-time P2P payment via Zelle network. | ❌ Phase 2 |

## Transaction Statuses

| Status | Definition | Can Customer Act? |
|--------|-----------|-------------------|
| **Pending** | Authorized but not yet posted. Funds held from available balance. | Cancel (if transfer), otherwise wait. |
| **Posted** | Fully processed and reflected in ledger balance. | No (contact support for disputes). |
| **Cancelled** | Transfer cancelled by customer before posting. Held funds released. | No further action. |
| **Failed** | Transfer or payment failed (insufficient funds, invalid recipient, etc.). | Retry or contact support. |
| **Reversed** | Posted transaction reversed (dispute, error correction). | Automatic — no action needed. |

## Authentication Terms

| Term | Definition |
|------|-----------|
| **MFA** | Multi-Factor Authentication — requires 2+ verification methods (something you know + something you have). |
| **TOTP** | Time-based One-Time Password — 6-digit code from authenticator app, changes every 30 seconds. |
| **Step-Up Authentication** | Additional authentication challenge triggered by sensitive operations (e.g., large transfer). |
| **Session** | Authenticated user context, stored as JWT with 15-minute sliding expiration. |
| **Biometric** | Authentication using body characteristics (fingerprint, face). Used on mobile devices. |

## Compliance Terms

| Term | Definition | Relevance |
|------|-----------|-----------|
| **GLBA** | Gramm-Leach-Bliley Act — requires financial institutions to protect customer data privacy. | Data handling, privacy notices. |
| **SOX** | Sarbanes-Oxley Act — requires audit trails for financial reporting. | 7-year log retention. |
| **PCI-DSS** | Payment Card Industry Data Security Standard — required if handling/displaying card data. | Phase 2 (if credit cards added). |
| **ADA** | Americans with Disabilities Act — requires digital accessibility (WCAG 2.1 AA). | All portal pages. |
| **Reg D** | Federal Reserve Regulation D — limits certain savings account withdrawals to 6/month. | Savings account transfers. |
| **BSA/AML** | Bank Secrecy Act / Anti-Money Laundering — requires suspicious activity reporting. | Transfer limits, velocity checks. |

## UX Terms

| Term | Definition |
|------|-----------|
| **Empty State** | UI shown when a section has no data (e.g., no transactions, no payees). Must include guidance. |
| **Loading Skeleton** | Placeholder animation shown while data loads (gray shimmer blocks matching content layout). |
| **Toast Notification** | Temporary message (3-5 seconds) at top of screen confirming an action (e.g., "Transfer submitted"). |
| **Inline Validation** | Real-time field validation as the user types (e.g., email format check). |
| **Step-Up Modal** | Dialog that appears mid-flow requiring additional verification before proceeding. |

## System Terms

| Term | Definition |
|------|-----------|
| **Core Banking API** | Contoso's existing backend system (Temenos T24) that manages accounts, transactions, and customer data. |
| **Bill Pay Processor** | Third-party service (Fiserv CheckFree) that handles bill payment routing and processing. |
| **Document Store** | Azure Blob Storage with lifecycle management for 7-year document retention. |
| **Audit Log** | Append-only log stored in Azure Table Storage, immutable, 7-year retention. |
