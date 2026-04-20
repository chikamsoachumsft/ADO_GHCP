# ADO Work Item Hierarchy — Customer Self-Service Portal

> Auto-generated from refined requirements. Ready to push to Azure DevOps.

---

## Visual Hierarchy

```
📦 EPIC: Authentication & Security Platform [55 SP]
├── 🔷 FEATURE: Multi-Factor Authentication
│   ├── 📋 US-101: Login page with email/password
│   ├── 📋 US-102: MFA setup flow (SMS + Authenticator)
│   ├── 📋 US-103: MFA challenge on login
│   └── 📋 US-104: Biometric login on mobile
├── 🔷 FEATURE: Session & Access Management
│   ├── 📋 US-105: Session timeout and concurrent limits
│   ├── 📋 US-106: Re-auth for sensitive operations
│   ├── 📋 US-107: Password reset with MFA
│   ├── 📋 US-108: Force logout all devices
│   └── 📋 US-109: Account lockout after failed attempts
└── 🔷 FEATURE: Security Hardening
    ├── 📋 US-110: Security headers and OWASP compliance
    └── 📋 US-111: Login audit logging

📦 EPIC: Account Dashboard [21 SP]
├── 🔷 FEATURE: Account Overview
│   ├── 📋 US-201: Account list with balances
│   └── 📋 US-202: Pending transactions display
└── 🔷 FEATURE: Transaction History
    ├── 📋 US-203: Transaction history (30-day default)
    ├── 📋 US-204: Transaction search and filter (18 months)
    └── 📋 US-205: Transaction export (CSV + PDF)

📦 EPIC: Fund Transfers [60 SP]
├── 🔷 FEATURE: Internal Transfers
│   ├── 📋 US-301: Transfer between own accounts
│   ├── 📋 US-302: Transfer to Contoso customer
│   ├── 📋 US-303: Transfer limits enforcement
│   └── 📋 US-304: Transfer cancellation (pending)
├── 🔷 FEATURE: Payee Management
│   ├── 📋 US-305: Payee CRUD operations
│   └── 📋 US-306: New payee 24-hour hold
├── 🔷 FEATURE: Transfer Safety
│   ├── 📋 US-307: Re-auth for transfers > $500
│   ├── 📋 US-308: Fraud velocity checks
│   └── 📋 US-309: Transfer confirmation + receipt
└── 🔷 FEATURE: Transfer History
    └── 📋 US-310: Transfer history and search

📦 EPIC: Bill Pay [34 SP]
├── 🔷 FEATURE: Biller Management
│   ├── 📋 US-401: Biller search and directory
│   └── 📋 US-402: Manual biller entry
├── 🔷 FEATURE: Payment Processing
│   ├── 📋 US-403: One-time payment
│   └── 📋 US-404: Payment history
└── 🔷 FEATURE: Recurring Payments
    ├── 📋 US-405: Recurring payment setup
    ├── 📋 US-406: Recurring payment management
    └── 📋 US-407: Payment reminders

📦 EPIC: Support Tickets [21 SP]
└── 🔷 FEATURE: Customer Support Portal
    ├── 📋 US-501: Ticket submission form
    ├── 📋 US-502: Ticket list and status tracking
    ├── 📋 US-503: Ticket detail and comment thread
    ├── 📋 US-504: Ticket reopen within 7 days
    └── 📋 US-505: SLA display

📦 EPIC: Document Upload [26 SP]
├── 🔷 FEATURE: File Upload Engine
│   ├── 📋 US-601: File upload (drag & drop + browse)
│   └── 📋 US-602: Virus scanning integration
└── 🔷 FEATURE: Document Workflow
    ├── 📋 US-603: Document request workflow
    ├── 📋 US-604: Document status tracking
    └── 📋 US-605: Document history (7-year view)

📦 EPIC: Notifications [34 SP]
├── 🔷 FEATURE: Notification Delivery
│   ├── 📋 US-701: Email notification service
│   ├── 📋 US-702: In-app notification center
│   └── 📋 US-703: Mandatory notification triggers
└── 🔷 FEATURE: Notification Preferences
    ├── 📋 US-704: Notification preferences UI
    ├── 📋 US-705: Notification preference enforcement
    └── 📋 US-706: Notification history

📦 EPIC: Profile Management [13 SP]
└── 🔷 FEATURE: Customer Profile
    ├── 📋 US-801: View profile page
    ├── 📋 US-802: Edit contact info (with verification)
    ├── 📋 US-803: Edit preferences and settings
    └── 📋 US-804: Change password
```

---

## Work Item Counts

| Type | Count |
|------|-------|
| Epics | 8 |
| Features | 17 |
| User Stories | 44 |
| **Total** | **69** |
