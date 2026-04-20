# Architecture Context — Customer Self-Service Portal

> **Purpose**: Provide technical context so that requirements analysis, estimation, and code generation account for real system constraints. This page prevents requirements that conflict with existing architecture.

---

## System Landscape

```
┌─────────────────────────────────────────────────────────────────┐
│                        Customer Devices                         │
│              (Browser / iOS App / Android App)                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTPS (TLS 1.3)
┌──────────────────────────▼──────────────────────────────────────┐
│                     Azure Front Door                             │
│              (WAF, DDoS Protection, CDN)                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│               Self-Service Portal (NEW)                         │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│   │  React SPA   │  │  .NET 8 API  │  │ SignalR Hub  │         │
│   │  (Frontend)  │  │  (Backend)   │  │ (Real-time)  │         │
│   └──────────────┘  └──────┬───────┘  └──────────────┘         │
│                            │                                     │
│   Azure App Service (Premium v3, P2v3)                           │
│   Deployment Slots: staging + production                         │
└────────────────────────────┬─────────────────────────────────────┘
                             │
        ┌────────────────────┼───────────────────────┐
        │                    │                       │
┌───────▼──────┐   ┌────────▼────────┐   ┌──────────▼────────┐
│ Core Banking │   │  Bill Pay       │   │  Notification     │
│ API (T24)    │   │  Processor      │   │  Service          │
│              │   │  (Fiserv)       │   │  (SendGrid)       │
│ On-prem      │   │  Third-party    │   │  SaaS             │
│ REST + mTLS  │   │  REST API       │   │  REST API         │
└──────────────┘   └─────────────────┘   └───────────────────┘
```

---

## Existing Systems (DO NOT Rebuild)

| System | Technology | Connection | Constraint |
|--------|-----------|------------|------------|
| Core Banking (T24) | Temenos T24, REST API | VPN + mTLS, on-prem | Rate limit: 100 req/sec. Downtime: Sun 2-6 AM ET. Response time: 200-800ms. |
| Bill Pay Processor | Fiserv CheckFree | REST API, API key auth | Cut-off: 4 PM ET. Batch settlement. |
| Email Service | SendGrid | REST API, API key | 100K emails/month plan. Template-based. |
| Identity Provider | Azure AD B2C | OIDC/OAuth 2.0 | Custom policies for MFA. Existing tenant. |
| Document Storage | Azure Blob Storage | Azure SDK / managed identity | Geo-redundant (RA-GRS). Lifecycle policies for 7-year retention. |

---

## Technology Stack (New Portal)

| Layer | Technology | Justification |
|-------|-----------|---------------|
| Frontend | React 18 + TypeScript | Existing team expertise. Component library: Fluent UI. |
| Backend API | .NET 8 (C#) | Core banking SDK available in .NET. Team has 5 .NET devs. |
| Real-time | SignalR | Notification bell updates, transaction alerts. |
| Database | Azure SQL Database (Serverless) | Session data, preferences, audit cache. NOT financial data (that's in T24). |
| Cache | Azure Redis Cache | Session tokens, rate limiting, frequently accessed data. |
| File Storage | Azure Blob Storage | Document uploads with virus scanning (Microsoft Defender for Storage). |
| Hosting | Azure App Service P2v3 | Deployment slots for blue/green. VNet integration for T24 connectivity. |
| CDN / WAF | Azure Front Door Premium | Global distribution, WAF rules, DDoS protection. |
| Monitoring | Application Insights + Log Analytics | APM, custom metrics, KQL queries. |
| CI/CD | Azure DevOps Pipelines + GitHub Actions | ADO for planning, GH for code + Copilot agent. |

---

## API Contract with Core Banking (T24)

### Available Endpoints (Already Exist)

| Endpoint | Method | Purpose | Response Time |
|----------|--------|---------|---------------|
| `/api/v2/customers/{id}/accounts` | GET | List all accounts for a customer | ~300ms |
| `/api/v2/accounts/{id}/balance` | GET | Get current and available balance | ~200ms |
| `/api/v2/accounts/{id}/transactions` | GET | List transactions (paginated, filterable) | ~500ms |
| `/api/v2/transfers/internal` | POST | Create internal transfer | ~800ms |
| `/api/v2/transfers/{id}` | GET | Get transfer status | ~200ms |
| `/api/v2/transfers/{id}/cancel` | POST | Cancel pending transfer | ~400ms |
| `/api/v2/customers/{id}/profile` | GET/PATCH | Read/update customer profile | ~300ms |

### NOT Available (Must Be Built or Requested)

| Capability | Status | Impact |
|-----------|--------|--------|
| Real-time transaction events (webhook/event) | Requested from T24 team | Need for real-time notifications. Fallback: poll every 30s. |
| Payee management API | Does not exist in T24 | Must store payees in portal's own Azure SQL. |
| Document request events | Does not exist | Must build custom workflow in portal. |

---

## Security Architecture

```
Customer → Azure Front Door (WAF) → App Service (VNet) → Core Banking (mTLS via VPN)
                                                        → Redis (private endpoint)
                                                        → SQL Database (private endpoint)
                                                        → Blob Storage (private endpoint)
```

- All Azure resources in **private VNet** (no public endpoints except Front Door)
- Core Banking connection via **Site-to-Site VPN** with **mutual TLS**
- Managed Identity for all Azure service-to-service auth (no connection strings in code)
- Key Vault for third-party secrets (SendGrid API key, Fiserv API key)

---

## Performance Budgets

| Metric | Target | Measurement |
|--------|--------|------------|
| First Contentful Paint | < 1.5s | Lighthouse, P75 |
| Time to Interactive | < 3.0s | Lighthouse, P75 |
| API Response (internal) | < 500ms | Application Insights, P95 |
| API Response (via T24) | < 1.5s | Application Insights, P95 (includes T24 latency) |
| JS Bundle Size | < 300 KB gzipped | Build output |
| Concurrent Users | 10,000 | Load test (k6) |

---

## Environment Strategy

| Environment | Purpose | Core Banking | Data |
|------------|---------|-------------|------|
| `dev` | Feature development | Mock API | Synthetic |
| `staging` | Integration testing | T24 Sandbox | Masked production data |
| `production` | Live | T24 Production | Real |

All environments deployed via identical IaC (Bicep) with environment-specific parameters.
