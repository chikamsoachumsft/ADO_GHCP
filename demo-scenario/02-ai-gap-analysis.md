# AI Gap Analysis — Customer Self-Service Portal

> **Analysis of**: `01-project-brief.md`  
> **Gaps Found**: 23 across 7 categories  
> **Risk Level**: HIGH — requirements are insufficient for estimation or development

---

## Summary

The stakeholder brief provides a reasonable high-level vision but is missing critical details required for a financial services application. The brief has **no security requirements**, **no compliance mentions**, **no performance targets**, **no accessibility requirements**, and **no error handling specifications**. Proceeding without addressing these gaps would result in significant rework, scope creep, and potential regulatory risk.

---

## 🔴 Critical Gaps (Must Address Before Development)

### 1. Security & Authentication (6 gaps)

| # | Gap | Risk | Question for Stakeholder |
|---|-----|------|--------------------------|
| G-01 | No authentication method specified | HIGH | MFA required? SSO with existing banking login? Biometric on mobile? |
| G-02 | No session management requirements | HIGH | Session timeout duration? Re-auth for sensitive operations? |
| G-03 | No authorization model | HIGH | Role-based access? Joint account holders? Power of attorney? |
| G-04 | No data encryption requirements stated | HIGH | At-rest and in-transit encryption standards? TLS version? |
| G-05 | "Needs to be secure" is not a requirement | HIGH | Which security standards? OWASP Top 10? Pen testing? |
| G-06 | No fraud detection mentioned | HIGH | Transfer limits? Velocity checks? Suspicious activity alerts? |

### 2. Regulatory & Compliance (4 gaps)

| # | Gap | Risk | Question for Stakeholder |
|---|-----|------|--------------------------|
| G-07 | No regulatory compliance mentioned | CRITICAL | SOX? PCI-DSS? GLBA? State-specific regulations? |
| G-08 | No audit trail requirements | HIGH | Which actions must be logged? Retention period? |
| G-09 | No data residency requirements | MEDIUM | Where must data be stored? Cross-border restrictions? |
| G-10 | No accessibility compliance | HIGH | WCAG 2.1 AA required? ADA compliance? |

### 3. Fund Transfer Specifics (4 gaps)

| # | Gap | Risk | Question for Stakeholder |
|---|-----|------|--------------------------|
| G-11 | No transfer limits specified | HIGH | Daily/per-transaction limits? Different limits by account type? |
| G-12 | No mention of external transfers | MEDIUM | ACH? Wire transfers? Zelle? Or internal only? |
| G-13 | No cut-off times or processing windows | MEDIUM | Real-time vs batch? Business days only? |
| G-14 | No reversal or cancellation flow | HIGH | Can customers cancel pending transfers? Dispute process? |

---

## 🟡 Important Gaps (Should Address Before Sprint Planning)

### 4. Non-Functional Requirements (3 gaps)

| # | Gap | Risk | Question for Stakeholder |
|---|-----|------|--------------------------|
| G-15 | No performance requirements | MEDIUM | Expected response times? Concurrent user targets? |
| G-16 | No availability/SLA targets | MEDIUM | 99.9%? 99.99%? Planned maintenance windows? |
| G-17 | No scalability requirements | MEDIUM | Expected user base? Growth projections? Peak load times? |

### 5. Document Upload Specifics (3 gaps)

| # | Gap | Risk | Question for Stakeholder |
|---|-----|------|--------------------------|
| G-18 | No file type/size restrictions | MEDIUM | Allowed formats? Max file size? Virus scanning? |
| G-19 | No document retention policy | HIGH | How long are documents stored? Auto-deletion? |
| G-20 | No document verification workflow | MEDIUM | Manual review? AI-assisted verification? SLA for review? |

### 6. Notification Details (2 gaps)

| # | Gap | Risk | Question for Stakeholder |
|---|-----|------|--------------------------|
| G-21 | No notification channels specified | MEDIUM | Email? SMS? Push notifications? In-app? All of the above? |
| G-22 | No notification preferences/opt-out | MEDIUM | Can customers choose which notifications? Regulatory requirements for mandatory alerts? |

---

## 🟢 Minor Gaps (Address During Design)

### 7. UX & Integration (1 gap)

| # | Gap | Risk | Question for Stakeholder |
|---|-----|------|--------------------------|
| G-23 | "Look modern" is subjective | LOW | Design system? Brand guidelines? Competitor benchmarks? |

---

## Ambiguities Detected

| Brief Says | Ambiguity | Interpretation Options |
|---|---|---|
| "manage their accounts" | Which account types? | Checking only? Savings? Loans? Credit cards? Investment? |
| "recent transactions" | How far back? | 30 days? 90 days? Full history with search? |
| "other Contoso customers" | How are recipients identified? | By account number? By email/phone? Saved payee list? |
| "documents we request" | Who initiates the request? | Automated requests? Manual from back-office? Both? |
| "important account activity" | What qualifies as important? | All transactions? Only above threshold? Security events? |
| "Phase 1 by end of Q3" | What's in Phase 1 vs Phase 2? | All 7 features? A subset? MVP? |

---

## Recommendation

Before proceeding to work item creation, the following must be resolved:

1. **Mandatory**: G-01 through G-10 (Security + Compliance) — these are non-negotiable for a financial application
2. **Strongly Recommended**: G-11 through G-14 (Transfer logic) — core feature, can't estimate without details
3. **Recommended**: Hold a 2-hour requirements workshop using the questions above as an agenda

> **Next Step**: Review refined requirements in `03-refined-requirements.md` where AI has filled gaps with industry-standard defaults and marked assumptions for stakeholder validation.
