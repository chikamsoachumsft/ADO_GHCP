<#
.SYNOPSIS
    Push 7 of 8 epics to ADO (excludes Profile Management for live demo).
#>

$ErrorActionPreference = "Stop"

$Org = "https://dev.azure.com/canayorachu"
$Project = "Contoso-SelfService-Portal"
$Pat = $env:ADO_PAT

$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$headers = @{ Authorization = "Basic $base64Auth"; "Content-Type" = "application/json-patch+json" }

$created = 0
$failed = 0

function New-WI {
    param([string]$Type, [string]$Title, [string]$Desc, [string]$AC, [int]$SP, [int]$Pri, [string]$Tags, [int]$ParentId)
    $body = @( @{ op = "add"; path = "/fields/System.Title"; value = $Title }, @{ op = "add"; path = "/fields/System.Description"; value = $Desc } )
    if ($AC) { $body += @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.AcceptanceCriteria"; value = ($AC -replace "`n","<br/>") } }
    if ($SP -gt 0) {
        $f = if ($Type -eq "User Story") { "/fields/Microsoft.VSTS.Scheduling.StoryPoints" } else { "/fields/Microsoft.VSTS.Scheduling.Effort" }
        $body += @{ op = "add"; path = $f; value = $SP }
    }
    if ($Pri -gt 0) { $body += @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.Priority"; value = $Pri } }
    if ($Tags) { $body += @{ op = "add"; path = "/fields/System.Tags"; value = ($Tags -replace ";","; ") } }
    if ($ParentId -gt 0) { $body += @{ op = "add"; path = "/relations/-"; value = @{ rel = "System.LinkTypes.Hierarchy-Reverse"; url = "$Org/$Project/_apis/wit/workItems/$ParentId" } } }
    $encodedType = [System.Uri]::EscapeDataString($Type)
    $url = "$Org/$Project/_apis/wit/workitems/`$$encodedType`?api-version=7.1"
    $json = $body | ConvertTo-Json -Depth 5
    try {
        $r = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($json))
        Write-Host "  Created #$($r.id) [$Type] $Title" -ForegroundColor Green
        $script:created++
        return $r.id
    } catch {
        Write-Host "  FAIL [$Type] $Title - $($_.Exception.Message)" -ForegroundColor Red
        $script:failed++
        return 0
    }
}

Write-Host "=== Pushing 7 epics (excluding Profile Management) ===" -ForegroundColor Yellow

# ═══ EPIC 1: Auth ═══
Write-Host "`n[1/7] Authentication and Security" -ForegroundColor Cyan
$e1 = New-WI -Type "Epic" -Title "Authentication & Security Platform" -Desc "Comprehensive auth: MFA, session management, OWASP hardening." -AC "- MFA enforced for all logins`n- 15-min session timeout`n- Re-auth for sensitive ops`n- All events audit-logged" -SP 55 -Pri 1 -Tags "security;phase-1"
$f1a = New-WI -Type "Feature" -Title "Multi-Factor Authentication" -Desc "SMS OTP, authenticator app, and biometric login." -SP 24 -Pri 1 -Tags "security;mfa" -ParentId $e1
New-WI -Type "User Story" -Title "Login page with email and password" -Desc "As a customer, I want to log in with my email and password." -AC "Given valid credentials, Then prompted for MFA`nGiven invalid credentials, Then generic error" -SP 3 -Pri 1 -Tags "login" -ParentId $f1a | Out-Null
New-WI -Type "User Story" -Title "MFA setup flow (SMS + Authenticator)" -Desc "As a customer, I want to set up multi-factor authentication." -AC "Given first login, Then guided through MFA setup`nGiven SMS chosen, Then phone verification via OTP`nGiven Authenticator, Then QR code + TOTP verification" -SP 8 -Pri 1 -Tags "mfa" -ParentId $f1a | Out-Null
New-WI -Type "User Story" -Title "MFA challenge on login" -Desc "As a customer, I want to verify identity with second factor on every login." -AC "Given valid password, Then MFA prompt`nGiven correct code within 60s, Then authenticated`nGiven wrong code 3 times, Then account locked" -SP 5 -Pri 1 -Tags "mfa" -ParentId $f1a | Out-Null
New-WI -Type "User Story" -Title "Biometric login on mobile" -Desc "As a mobile customer, I want to use Face ID or fingerprint to log in." -AC "Given iOS, Then Face ID supported`nGiven Android, Then fingerprint supported`nGiven biometric fails, Then fallback to password + MFA" -SP 8 -Pri 2 -Tags "mobile;biometric" -ParentId $f1a | Out-Null
$f1b = New-WI -Type "Feature" -Title "Session & Access Management" -Desc "JWT sessions, timeouts, concurrent limits, lockout." -SP 23 -Pri 1 -Tags "security;sessions" -ParentId $e1
New-WI -Type "User Story" -Title "Session timeout and concurrent device limits" -Desc "As a security officer, I want sessions to expire and limit concurrent logins." -AC "Given 15 min inactivity, Then session expires`nGiven 3 active sessions, Then 4th terminates oldest" -SP 5 -Pri 1 -Tags "sessions" -ParentId $f1b | Out-Null
New-WI -Type "User Story" -Title "Re-authentication for sensitive operations" -Desc "As a customer, I want to re-verify identity for sensitive operations." -AC "Given transfer > 500, Then MFA required`nGiven email/phone change, Then MFA required" -SP 5 -Pri 1 -Tags "step-up-auth" -ParentId $f1b | Out-Null
New-WI -Type "User Story" -Title "Password reset with MFA verification" -Desc "As a customer, I want to reset my password securely." -AC "Given forgot password, Then email reset link (30 min valid)`nGiven reset link, Then MFA required before new password" -SP 5 -Pri 1 -Tags "password" -ParentId $f1b | Out-Null
New-WI -Type "User Story" -Title "Force logout from all devices" -Desc "As a customer, I want to log out of all devices." -AC "Given force logout clicked, Then all tokens invalidated`nGiven other devices, Then redirect to login" -SP 3 -Pri 2 -Tags "sessions" -ParentId $f1b | Out-Null
New-WI -Type "User Story" -Title "Account lockout after failed attempts" -Desc "As a security officer, I want accounts locked after repeated failures." -AC "Given 3 failures in 10 min, Then warning sent`nGiven 5 failures, Then locked 30 min`nGiven 10 in 24h, Then locked until support" -SP 5 -Pri 1 -Tags "lockout" -ParentId $f1b | Out-Null
$f1c = New-WI -Type "Feature" -Title "Security Hardening" -Desc "OWASP headers, rate limiting, audit logging." -SP 8 -Pri 1 -Tags "security;owasp" -ParentId $e1
New-WI -Type "User Story" -Title "Security headers and OWASP compliance" -Desc "As a security officer, I want security headers on all responses." -AC "Given any response, Then CSP + HSTS + X-Frame-Options present`nGiven rate limit exceeded, Then 429 returned" -SP 5 -Pri 1 -Tags "owasp" -ParentId $f1c | Out-Null
New-WI -Type "User Story" -Title "Login audit logging" -Desc "As a compliance officer, I want all auth events logged." -AC "Given any auth event, Then logged with timestamp, customer ID, IP, user agent, outcome" -SP 3 -Pri 1 -Tags "audit" -ParentId $f1c | Out-Null

# ═══ EPIC 2: Dashboard ═══
Write-Host "`n[2/7] Account Dashboard" -ForegroundColor Cyan
$e2 = New-WI -Type "Epic" -Title "Account Dashboard" -Desc "Account overview with balances, transaction history, search, and export." -SP 21 -Pri 2 -Tags "dashboard;phase-1"
$f2a = New-WI -Type "Feature" -Title "Account Overview" -Desc "Display all accounts with balances and pending indicators." -SP 8 -Pri 2 -Tags "dashboard" -ParentId $e2
New-WI -Type "User Story" -Title "Account list with balances" -Desc "As a customer, I want to see all my accounts with balances on the dashboard." -AC "Given authenticated, Then see cards for each account with nickname, last 4 digits, type, balances`nGiven loading, Then skeleton shown, loads < 2s" -SP 5 -Pri 1 -Tags "dashboard" -ParentId $f2a | Out-Null
New-WI -Type "User Story" -Title "Pending transactions display" -Desc "As a customer, I want to see pending transactions separately." -AC "Given pending transactions, Then shown with Pending badge`nGiven total pending, Then shown next to available balance" -SP 3 -Pri 2 -Tags "pending" -ParentId $f2a | Out-Null
$f2b = New-WI -Type "Feature" -Title "Transaction History" -Desc "Searchable history with filtering, pagination, and export." -SP 13 -Pri 2 -Tags "transactions" -ParentId $e2
New-WI -Type "User Story" -Title "Transaction history with 30-day default" -Desc "As a customer, I want to see my recent transactions." -AC "Given account view, Then last 30 days shown`nGiven each row, Then date, description, category, amount, running balance`nGiven pagination, Then 25/50/100 per page" -SP 5 -Pri 1 -Tags "transactions" -ParentId $f2b | Out-Null
New-WI -Type "User Story" -Title "Transaction search and filter" -Desc "As a customer, I want to search and filter transaction history (up to 18 months)." -AC "Given filters, Then date range, amount range, keyword, type`nGiven results, Then < 500ms`nGiven active filters, Then shown as removable chips" -SP 5 -Pri 2 -Tags "search" -ParentId $f2b | Out-Null
New-WI -Type "User Story" -Title "Transaction export (CSV and PDF)" -Desc "As a customer, I want to export transactions." -AC "Given CSV clicked, Then CSV downloads`nGiven PDF clicked, Then formatted PDF`nGiven > 10K rows, Then server-side generation with progress" -SP 3 -Pri 3 -Tags "export" -ParentId $f2b | Out-Null

# ═══ EPIC 3: Transfers ═══
Write-Host "`n[3/7] Fund Transfers" -ForegroundColor Cyan
$e3 = New-WI -Type "Epic" -Title "Fund Transfers" -Desc "Internal transfers, payee management, limits, fraud checks." -SP 60 -Pri 1 -Tags "transfers;phase-1;high-risk"
$f3a = New-WI -Type "Feature" -Title "Internal Transfers" -Desc "Between own accounts and to other Contoso customers." -SP 24 -Pri 1 -Tags "transfers" -ParentId $e3
New-WI -Type "User Story" -Title "Transfer between own accounts" -Desc "As a customer, I want to transfer money between my own accounts." -AC "Given 2+ accounts and valid amount, Then real-time transfer`nGiven amount > available, Then Insufficient funds error" -SP 8 -Pri 1 -Tags "internal" -ParentId $f3a | Out-Null
New-WI -Type "User Story" -Title "Transfer to another Contoso customer" -Desc "As a customer, I want to send money to other Contoso customers." -AC "Given recipient info, Then validate recipient exists`nGiven business hours, Then real-time`nGiven outside hours, Then queued next business day" -SP 8 -Pri 1 -Tags "p2p" -ParentId $f3a | Out-Null
New-WI -Type "User Story" -Title "Transfer limits enforcement" -Desc "As a risk officer, I want transfer limits enforced." -AC "Given per-tx > 2500, Then rejected`nGiven daily total > 5000, Then rejected until next day" -SP 8 -Pri 1 -Tags "limits" -ParentId $f3a | Out-Null
New-WI -Type "User Story" -Title "Cancel pending transfer" -Desc "As a customer, I want to cancel pending transfers." -AC "Given pending transfer, Then Cancel with confirmation`nGiven confirmed, Then status = Cancelled, funds released" -SP 5 -Pri 2 -Tags "cancel" -ParentId $f3a | Out-Null
$f3b = New-WI -Type "Feature" -Title "Payee Management" -Desc "Save, edit, delete payees with fraud prevention hold." -SP 10 -Pri 2 -Tags "payees" -ParentId $e3
New-WI -Type "User Story" -Title "Payee CRUD operations" -Desc "As a customer, I want to save, edit, and delete payees." -AC "Given new payee, Then enter name, account, routing, nickname`nGiven delete, Then confirmation dialog" -SP 5 -Pri 2 -Tags "payees" -ParentId $f3b | Out-Null
New-WI -Type "User Story" -Title "New payee 24-hour hold" -Desc "As a risk officer, I want 24-hour holds on first transfers to new payees." -AC "Given new payee < 24h, Then first transfer held 24h`nGiven 24h elapsed, Then transfers normal" -SP 5 -Pri 1 -Tags "fraud-prevention" -ParentId $f3b | Out-Null
$f3c = New-WI -Type "Feature" -Title "Transfer Safety" -Desc "Step-up auth, fraud velocity checks, confirmation receipts." -SP 16 -Pri 1 -Tags "fraud;security" -ParentId $e3
New-WI -Type "User Story" -Title "Re-authentication for transfers over 500" -Desc "As a customer, I want to confirm identity for large transfers." -AC "Given transfer > 500, Then MFA challenge`nGiven MFA verified, Then 5-min elevated session`nGiven MFA fails, Then transfer cancelled" -SP 5 -Pri 1 -Tags "step-up" -ParentId $f3c | Out-Null
New-WI -Type "User Story" -Title "Fraud velocity checks" -Desc "As a risk officer, I want velocity checks on transfers." -AC "Given > 5 transfers in 10 min, Then 6th blocked + alert`nGiven 3+ velocity blocks in 24h, Then manual review" -SP 8 -Pri 1 -Tags "fraud" -ParentId $f3c | Out-Null
New-WI -Type "User Story" -Title "Transfer confirmation and receipt" -Desc "As a customer, I want confirmation and receipt after transfers." -AC "Given success, Then confirmation screen + email receipt`nGiven Print Receipt, Then printer-friendly version" -SP 3 -Pri 2 -Tags "receipt" -ParentId $f3c | Out-Null
$f3d = New-WI -Type "Feature" -Title "Transfer History" -Desc "Dedicated transfer history with search and filters." -SP 5 -Pri 3 -Tags "history" -ParentId $e3
New-WI -Type "User Story" -Title "Transfer history and search" -Desc "As a customer, I want to view and search transfer history." -AC "Given history page, Then all transfers listed with status filter`nGiven export, Then CSV download" -SP 5 -Pri 3 -Tags "history" -ParentId $f3d | Out-Null

# ═══ EPIC 4: Bill Pay ═══
Write-Host "`n[4/7] Bill Pay" -ForegroundColor Cyan
$e4 = New-WI -Type "Epic" -Title "Bill Pay" -Desc "One-time and scheduled bill payment, biller directory." -SP 43 -Pri 2 -Tags "bill-pay;phase-2"
$f4a = New-WI -Type "Feature" -Title "One-Time Payments" -Desc "Pay bills manually from any account." -SP 13 -Pri 2 -Tags "bill-pay" -ParentId $e4
New-WI -Type "User Story" -Title "Pay a bill from any linked account" -Desc "As a customer, I want to pay bills from any of my accounts." -AC "Given biller and amount, Then choose source account`nGiven insufficient funds, Then error shown`nGiven success, Then confirmation with delivery date" -SP 5 -Pri 1 -Tags "bill-pay" -ParentId $f4a | Out-Null
New-WI -Type "User Story" -Title "Biller directory search and add" -Desc "As a customer, I want to find and add billers." -AC "Given search term, Then typeahead suggestions after 2 chars`nGiven biller selected, Then pre-filled payment fields`nGiven custom biller, Then manual entry form" -SP 5 -Pri 2 -Tags "billers" -ParentId $f4a | Out-Null
New-WI -Type "User Story" -Title "Payment confirmation with expected delivery date" -Desc "As a customer, I want to know when my bill payment will arrive." -AC "Given payment submitted, Then show expected delivery (2-5 business days)`nGiven expedited available, Then option to pay fee for 1-day delivery" -SP 3 -Pri 2 -Tags "confirmation" -ParentId $f4a | Out-Null
$f4b = New-WI -Type "Feature" -Title "Scheduled Payments" -Desc "Auto-pay, recurring schedules, skip/modify." -SP 18 -Pri 2 -Tags "recurring" -ParentId $e4
New-WI -Type "User Story" -Title "Recurring bill payment setup" -Desc "As a customer, I want to set up automatic recurring payments." -AC "Given recurring setup, Then select frequency (weekly/biweekly/monthly)`nGiven start date, Then first payment scheduled`nGiven end date or 'until cancelled', Then schedule respects that" -SP 8 -Pri 1 -Tags "recurring" -ParentId $f4b | Out-Null
New-WI -Type "User Story" -Title "Edit or cancel scheduled payment" -Desc "As a customer, I want to modify or cancel scheduled payments." -AC "Given editing, Then change amount, date, account, frequency`nGiven cancel, Then confirmation dialog`nGiven already processing, Then Cannot modify message" -SP 5 -Pri 2 -Tags "scheduled" -ParentId $f4b | Out-Null
New-WI -Type "User Story" -Title "Skip a single occurrence" -Desc "As a customer, I want to skip one payment in a recurring series." -AC "Given skip requested, Then that occurrence skipped`nGiven next occurrence, Then resumes normally`nGiven notification, Then email confirms the skip" -SP 5 -Pri 3 -Tags "skip" -ParentId $f4b | Out-Null
$f4c = New-WI -Type "Feature" -Title "Payment Tracking" -Desc "Payment history, status tracking, receipt generation." -SP 7 -Pri 3 -Tags "history" -ParentId $e4
New-WI -Type "User Story" -Title "Bill payment history" -Desc "As a customer, I want to view my bill payment history." -AC "Given history page, Then all payments listed with biller, amount, date, status`nGiven filter, Then by biller, date range, status" -SP 3 -Pri 3 -Tags "history" -ParentId $f4c | Out-Null
New-WI -Type "User Story" -Title "E-bill and paperless statements" -Desc "As a customer, I want to receive e-bills and go paperless." -AC "Given supported biller, Then e-bill received in dashboard`nGiven paperless opt-in, Then paper statements stopped" -SP 3 -Pri 3 -Tags "e-bill" -ParentId $f4c | Out-Null

# ═══ EPIC 5: Customer Support ═══
Write-Host "`n[5/7] Customer Support" -ForegroundColor Cyan
$e5 = New-WI -Type "Epic" -Title "Customer Support Portal" -Desc "Support ticket system, transaction disputes, secure messaging." -SP 55 -Pri 2 -Tags "support;phase-2"
$f5a = New-WI -Type "Feature" -Title "Support Ticket System" -Desc "Create, track, and manage support tickets." -SP 18 -Pri 2 -Tags "tickets" -ParentId $e5
New-WI -Type "User Story" -Title "Create support ticket" -Desc "As a customer, I want to create a support ticket." -AC "Given creation form, Then select category, priority, description`nGiven submission, Then ticket number assigned and displayed" -SP 5 -Pri 1 -Tags "tickets" -ParentId $f5a | Out-Null
New-WI -Type "User Story" -Title "Track ticket status" -Desc "As a customer, I want to track my ticket status." -AC "Given ticket list, Then status badges (Open, In Progress, Waiting, Resolved, Closed)`nGiven status change, Then notification sent" -SP 3 -Pri 2 -Tags "status" -ParentId $f5a | Out-Null
New-WI -Type "User Story" -Title "Add comments and attachments to tickets" -Desc "As a customer, I want to add context to my support tickets." -AC "Given open ticket, Then add comment and attachments (< 10MB)`nGiven new comment from support, Then notification sent" -SP 5 -Pri 2 -Tags "comments" -ParentId $f5a | Out-Null
New-WI -Type "User Story" -Title "Reopen resolved ticket" -Desc "As a customer, I want to reopen a resolved ticket if my issue persists." -AC "Given resolved < 7 days, Then Reopen button available`nGiven reopened, Then status returns to Open with history preserved" -SP 3 -Pri 3 -Tags "reopen" -ParentId $f5a | Out-Null
$f5b = New-WI -Type "Feature" -Title "Transaction Disputes" -Desc "File and track disputes on transactions with provisional credit." -SP 16 -Pri 1 -Tags "disputes" -ParentId $e5
New-WI -Type "User Story" -Title "File a transaction dispute" -Desc "As a customer, I want to dispute a transaction." -AC "Given any transaction, Then Dispute button`nGiven dispute filed, Then reason selection and description`nGiven filed, Then estimated resolution date shown (10 days)" -SP 8 -Pri 1 -Tags "disputes" -ParentId $f5b | Out-Null
New-WI -Type "User Story" -Title "Provisional credit for disputes" -Desc "As a customer, I want provisional credit while my dispute is investigated." -AC "Given eligible dispute > 2 days, Then provisional credit applied`nGiven credit applied, Then labeled as Provisional in balance" -SP 5 -Pri 1 -Tags "provisional-credit" -ParentId $f5b | Out-Null
New-WI -Type "User Story" -Title "Dispute resolution notification" -Desc "As a customer, I want to know when my dispute is resolved." -AC "Given resolution, Then email and in-app notification`nGiven credit kept, Then provisional label removed`nGiven denied, Then provisional credit reversed with 3-day notice" -SP 3 -Pri 2 -Tags "notification" -ParentId $f5b | Out-Null
$f5c = New-WI -Type "Feature" -Title "Secure Messaging" -Desc "Secure, encrypted messaging with support reps." -SP 8 -Pri 3 -Tags "messaging" -ParentId $e5
New-WI -Type "User Story" -Title "Secure messaging with support" -Desc "As a customer, I want to message support securely." -AC "Given messaging, Then messages encrypted end-to-end`nGiven new reply, Then push + email notification`nGiven attachments, Then 5MB limit, no executables" -SP 5 -Pri 3 -Tags "messaging" -ParentId $f5c | Out-Null
New-WI -Type "User Story" -Title "Message history and search" -Desc "As a customer, I want to search through my message history." -AC "Given inbox, Then all conversations listed with dates`nGiven search, Then keyword search across all messages" -SP 3 -Pri 3 -Tags "search" -ParentId $f5c | Out-Null

# ═══ EPIC 6: Document Management ═══
Write-Host "`n[6/7] Document Management" -ForegroundColor Cyan
$e6 = New-WI -Type "Epic" -Title "Document Management" -Desc "Secure document upload, viewing, and management." -SP 31 -Pri 3 -Tags "documents;phase-2"
$f6a = New-WI -Type "Feature" -Title "Document Upload" -Desc "Upload documents with virus scanning." -SP 10 -Pri 3 -Tags "upload" -ParentId $e6
New-WI -Type "User Story" -Title "Upload documents (PDF, JPG)" -Desc "As a customer, I want to upload documents for my account." -AC "Given upload, Then PDF and JPG accepted (< 10MB)`nGiven upload, Then virus scan before storage`nGiven success, Then thumbnail preview shown" -SP 5 -Pri 2 -Tags "upload" -ParentId $f6a | Out-Null
New-WI -Type "User Story" -Title "Document categorization" -Desc "As a customer, I want my documents organized by category." -AC "Given upload, Then select category (Identification, Statements, Tax, Correspondence)`nGiven category, Then displayed in organized folder view" -SP 3 -Pri 3 -Tags "categories" -ParentId $f6a | Out-Null
$f6b = New-WI -Type "Feature" -Title "Document Viewing" -Desc "View, download, and manage stored documents." -SP 13 -Pri 3 -Tags "viewing" -ParentId $e6
New-WI -Type "User Story" -Title "Document library with preview" -Desc "As a customer, I want to browse and preview my documents." -AC "Given library, Then thumbnails with name, date, category`nGiven click, Then in-browser preview (PDF/image)`nGiven download, Then original quality file downloaded" -SP 5 -Pri 2 -Tags "preview" -ParentId $f6b | Out-Null
New-WI -Type "User Story" -Title "Document search" -Desc "As a customer, I want to find specific documents." -AC "Given search, Then keyword search across names and categories`nGiven filters, Then by category, date range, file type" -SP 3 -Pri 3 -Tags "search" -ParentId $f6b | Out-Null
New-WI -Type "User Story" -Title "Delete documents" -Desc "As a customer, I want to delete my uploaded documents." -AC "Given delete requested, Then confirmation dialog with file name`nGiven bank-required docs, Then delete button disabled with tooltip" -SP 3 -Pri 3 -Tags "delete" -ParentId $f6b | Out-Null
$f6c = New-WI -Type "Feature" -Title "E-Statements" -Desc "Auto-generated monthly e-statements." -SP 8 -Pri 2 -Tags "statements" -ParentId $e6
New-WI -Type "User Story" -Title "Monthly e-statement generation" -Desc "As a customer, I want to receive monthly e-statements." -AC "Given month end, Then e-statement generated and available in Documents`nGiven new statement, Then email notification sent`nGiven retention, Then 7 years of statements available" -SP 5 -Pri 2 -Tags "statements" -ParentId $f6c | Out-Null
New-WI -Type "User Story" -Title "E-statement opt-in and preferences" -Desc "As a customer, I want to manage my statement preferences." -AC "Given preferences, Then choose paperless or paper`nGiven paperless, Then only e-statements generated`nGiven paper selected, Then both paper and e-statement" -SP 3 -Pri 3 -Tags "preferences" -ParentId $f6c | Out-Null

# ═══ EPIC 7: Notifications ═══
Write-Host "`n[7/7] Notifications" -ForegroundColor Cyan
$e7 = New-WI -Type "Epic" -Title "Notifications & Alerts" -Desc "Multi-channel notifications: in-app, email, SMS, push." -SP 34 -Pri 2 -Tags "notifications;phase-2"
$f7a = New-WI -Type "Feature" -Title "Notification Center" -Desc "In-app notification bell with read/unread, grouping." -SP 13 -Pri 2 -Tags "in-app" -ParentId $e7
New-WI -Type "User Story" -Title "In-app notification bell" -Desc "As a customer, I want to see notifications in the app." -AC "Given notifications, Then bell icon shows unread count badge`nGiven click, Then dropdown with grouped notifications`nGiven Mark All Read, Then all marked as read" -SP 5 -Pri 1 -Tags "bell" -ParentId $f7a | Out-Null
New-WI -Type "User Story" -Title "Notification grouping and actions" -Desc "As a customer, I want notifications grouped and actionable." -AC "Given grouping, Then by type (security, transactions, support)`nGiven notification clicked, Then navigate to relevant screen`nGiven delete, Then removed from list" -SP 5 -Pri 2 -Tags "grouping" -ParentId $f7a | Out-Null
New-WI -Type "User Story" -Title "Notification history (90 days)" -Desc "As a customer, I want to review past notifications." -AC "Given notification page, Then 90-day history`nGiven filter, Then by type and read/unread`nGiven older, Then auto-purged" -SP 3 -Pri 3 -Tags "history" -ParentId $f7a | Out-Null
$f7b = New-WI -Type "Feature" -Title "Alert Configuration" -Desc "Custom alerts for balance, transactions, security events." -SP 13 -Pri 2 -Tags "alerts" -ParentId $e7
New-WI -Type "User Story" -Title "Custom balance alerts" -Desc "As a customer, I want alerts when balance drops below a threshold." -AC "Given alert configured, Then notify when balance < threshold`nGiven multiple accounts, Then separate thresholds per account`nGiven channel, Then choose email, SMS, push, or in-app" -SP 5 -Pri 1 -Tags "alerts;balance" -ParentId $f7b | Out-Null
New-WI -Type "User Story" -Title "Transaction amount alerts" -Desc "As a customer, I want alerts for large transactions." -AC "Given alert configured, Then notify when transaction > threshold`nGiven choice, Then debit only, credit only, or both" -SP 5 -Pri 2 -Tags "alerts;transactions" -ParentId $f7b | Out-Null
New-WI -Type "User Story" -Title "Security event notifications" -Desc "As a customer, I want to be notified of security events." -AC "Given login from new device, Then immediate notification`nGiven password change, Then confirmation notification`nGiven account locked, Then notification with unlock instructions" -SP 3 -Pri 1 -Tags "security;mandatory" -ParentId $f7b | Out-Null
$f7c = New-WI -Type "Feature" -Title "Notification Preferences" -Desc "Per-channel and per-type notification preferences." -SP 8 -Pri 3 -Tags "preferences" -ParentId $e7
New-WI -Type "User Story" -Title "Notification preferences management" -Desc "As a customer, I want to control which notifications I receive." -AC "Given preferences page, Then matrix of notification types vs channels`nGiven security notifications, Then cannot be disabled (mandatory)`nGiven save, Then preferences applied immediately" -SP 5 -Pri 2 -Tags "preferences" -ParentId $f7c | Out-Null
New-WI -Type "User Story" -Title "Quiet hours configuration" -Desc "As a customer, I want to set quiet hours for non-urgent notifications." -AC "Given quiet hours set (e.g., 10PM-7AM), Then non-urgent held until morning`nGiven security alerts, Then always delivered immediately regardless of quiet hours" -SP 3 -Pri 3 -Tags "quiet-hours" -ParentId $f7c | Out-Null

Write-Host "`n=== COMPLETE ===" -ForegroundColor Yellow
Write-Host "Created: $created items" -ForegroundColor Green
Write-Host "Failed:  $failed items" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
