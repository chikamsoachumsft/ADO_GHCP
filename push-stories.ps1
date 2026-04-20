<#
.SYNOPSIS
    Push user stories only — epics and features already exist from prior run.
    Feature IDs from prior run: 257,258,259,261,262,264,265,266,267,269,270,271,273,274,275,277,278,279,281,282,283
#>

$ErrorActionPreference = "Stop"
$Org = "https://dev.azure.com/canayorachu"
$Project = "Contoso-SelfService-Portal"
$Pat = $env:ADO_PAT
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$headers = @{ Authorization = "Basic $base64Auth"; "Content-Type" = "application/json-patch+json" }
$created = 0; $failed = 0

function New-US {
    param([string]$Title, [string]$Desc, [string]$AC, [int]$SP, [int]$Pri, [string]$Tags, [int]$ParentId)
    $body = @(
        @{ op = "add"; path = "/fields/System.Title"; value = $Title },
        @{ op = "add"; path = "/fields/System.Description"; value = $Desc }
    )
    if ($AC) { $body += @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.AcceptanceCriteria"; value = ($AC -replace "`n","<br/>") } }
    if ($SP -gt 0) { $body += @{ op = "add"; path = "/fields/Microsoft.VSTS.Scheduling.StoryPoints"; value = $SP } }
    if ($Pri -gt 0) { $body += @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.Priority"; value = $Pri } }
    if ($Tags) { $body += @{ op = "add"; path = "/fields/System.Tags"; value = ($Tags -replace ";","; ") } }
    if ($ParentId -gt 0) { $body += @{ op = "add"; path = "/relations/-"; value = @{ rel = "System.LinkTypes.Hierarchy-Reverse"; url = "$Org/$Project/_apis/wit/workItems/$ParentId" } } }
    $url = "$Org/$Project/_apis/wit/workitems/`$User%20Story?api-version=7.1"
    $json = $body | ConvertTo-Json -Depth 5
    try {
        $r = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($json))
        Write-Host "  #$($r.id) $Title" -ForegroundColor Green
        $script:created++
    } catch {
        Write-Host "  FAIL: $Title - $($_.Exception.Message)" -ForegroundColor Red
        $script:failed++
    }
}

Write-Host "Pushing user stories (features already created)..." -ForegroundColor Yellow

# Feature 257: Multi-Factor Authentication
Write-Host "`nMFA (F257)" -ForegroundColor Cyan
New-US -Title "Login page with email and password" -Desc "As a customer, I want to log in with my email and password." -AC "Given valid credentials, Then prompted for MFA`nGiven invalid credentials, Then generic error" -SP 3 -Pri 1 -Tags "login" -ParentId 257
New-US -Title "MFA setup flow (SMS + Authenticator)" -Desc "As a customer, I want to set up multi-factor authentication." -AC "Given first login, Then guided through MFA setup`nGiven SMS chosen, Then phone verification via OTP`nGiven Authenticator, Then QR code + TOTP verification" -SP 8 -Pri 1 -Tags "mfa" -ParentId 257
New-US -Title "MFA challenge on login" -Desc "As a customer, I want to verify identity with second factor on every login." -AC "Given valid password, Then MFA prompt`nGiven correct code within 60s, Then authenticated`nGiven wrong code 3 times, Then account locked" -SP 5 -Pri 1 -Tags "mfa" -ParentId 257
New-US -Title "Biometric login on mobile" -Desc "As a mobile customer, I want to use Face ID or fingerprint to log in." -AC "Given iOS, Then Face ID supported`nGiven Android, Then fingerprint supported`nGiven biometric fails, Then fallback to password + MFA" -SP 8 -Pri 2 -Tags "mobile; biometric" -ParentId 257

# Feature 258: Session & Access Management
Write-Host "Sessions (F258)" -ForegroundColor Cyan
New-US -Title "Session timeout and concurrent device limits" -Desc "As a security officer, I want sessions to expire and limit concurrent logins." -AC "Given 15 min inactivity, Then session expires`nGiven 3 active sessions, Then 4th terminates oldest" -SP 5 -Pri 1 -Tags "sessions" -ParentId 258
New-US -Title "Re-authentication for sensitive operations" -Desc "As a customer, I want to re-verify identity for sensitive operations." -AC "Given transfer > 500, Then MFA required`nGiven email/phone change, Then MFA required" -SP 5 -Pri 1 -Tags "step-up-auth" -ParentId 258
New-US -Title "Password reset with MFA verification" -Desc "As a customer, I want to reset my password securely." -AC "Given forgot password, Then email reset link (30 min valid)`nGiven reset link, Then MFA required before new password" -SP 5 -Pri 1 -Tags "password" -ParentId 258
New-US -Title "Force logout from all devices" -Desc "As a customer, I want to log out of all devices." -AC "Given force logout clicked, Then all tokens invalidated`nGiven other devices, Then redirect to login" -SP 3 -Pri 2 -Tags "sessions" -ParentId 258
New-US -Title "Account lockout after failed attempts" -Desc "As a security officer, I want accounts locked after repeated failures." -AC "Given 3 failures in 10 min, Then warning sent`nGiven 5 failures, Then locked 30 min`nGiven 10 in 24h, Then locked until support" -SP 5 -Pri 1 -Tags "lockout" -ParentId 258

# Feature 259: Security Hardening
Write-Host "Security (F259)" -ForegroundColor Cyan
New-US -Title "Security headers and OWASP compliance" -Desc "As a security officer, I want security headers on all responses." -AC "Given any response, Then CSP + HSTS + X-Frame-Options present`nGiven rate limit exceeded, Then 429 returned" -SP 5 -Pri 1 -Tags "owasp" -ParentId 259
New-US -Title "Login audit logging" -Desc "As a compliance officer, I want all auth events logged." -AC "Given any auth event, Then logged with timestamp, customer ID, IP, user agent, outcome" -SP 3 -Pri 1 -Tags "audit" -ParentId 259

# Feature 261: Account Overview
Write-Host "Dashboard (F261, F262)" -ForegroundColor Cyan
New-US -Title "Account list with balances" -Desc "As a customer, I want to see all my accounts with balances on the dashboard." -AC "Given authenticated, Then see cards for each account with nickname, last 4 digits, type, balances`nGiven loading, Then skeleton shown, loads < 2s" -SP 5 -Pri 1 -Tags "dashboard" -ParentId 261
New-US -Title "Pending transactions display" -Desc "As a customer, I want to see pending transactions separately." -AC "Given pending transactions, Then shown with Pending badge`nGiven total pending, Then shown next to available balance" -SP 3 -Pri 2 -Tags "pending" -ParentId 261

# Feature 262: Transaction History
New-US -Title "Transaction history with 30-day default" -Desc "As a customer, I want to see my recent transactions." -AC "Given account view, Then last 30 days shown`nGiven each row, Then date, description, category, amount, running balance" -SP 5 -Pri 1 -Tags "transactions" -ParentId 262
New-US -Title "Transaction search and filter" -Desc "As a customer, I want to search and filter transaction history (up to 18 months)." -AC "Given filters, Then date range, amount range, keyword, type`nGiven results, Then < 500ms" -SP 5 -Pri 2 -Tags "search" -ParentId 262
New-US -Title "Transaction export (CSV and PDF)" -Desc "As a customer, I want to export transactions." -AC "Given CSV clicked, Then CSV downloads`nGiven PDF clicked, Then formatted PDF" -SP 3 -Pri 3 -Tags "export" -ParentId 262

# Feature 264: Internal Transfers
Write-Host "Transfers (F264-F267)" -ForegroundColor Cyan
New-US -Title "Transfer between own accounts" -Desc "As a customer, I want to transfer money between my own accounts." -AC "Given 2+ accounts and valid amount, Then real-time transfer`nGiven amount > available, Then Insufficient funds error" -SP 8 -Pri 1 -Tags "internal" -ParentId 264
New-US -Title "Transfer to another Contoso customer" -Desc "As a customer, I want to send money to other Contoso customers." -AC "Given recipient info, Then validate recipient exists`nGiven business hours, Then real-time`nGiven outside hours, Then queued" -SP 8 -Pri 1 -Tags "p2p" -ParentId 264
New-US -Title "Transfer limits enforcement" -Desc "As a risk officer, I want transfer limits enforced." -AC "Given per-tx > 2500, Then rejected`nGiven daily total > 5000, Then rejected until next day" -SP 8 -Pri 1 -Tags "limits" -ParentId 264
New-US -Title "Cancel pending transfer" -Desc "As a customer, I want to cancel pending transfers." -AC "Given pending transfer, Then Cancel with confirmation`nGiven confirmed, Then status = Cancelled, funds released" -SP 5 -Pri 2 -Tags "cancel" -ParentId 264

# Feature 265: Payee Management
New-US -Title "Payee CRUD operations" -Desc "As a customer, I want to save, edit, and delete payees." -AC "Given new payee, Then enter name, account, routing, nickname`nGiven delete, Then confirmation dialog" -SP 5 -Pri 2 -Tags "payees" -ParentId 265
New-US -Title "New payee 24-hour hold" -Desc "As a risk officer, I want 24-hour holds on first transfers to new payees." -AC "Given new payee < 24h, Then first transfer held 24h`nGiven 24h elapsed, Then transfers normal" -SP 5 -Pri 1 -Tags "fraud-prevention" -ParentId 265

# Feature 266: Transfer Safety
New-US -Title "Re-authentication for transfers over 500" -Desc "As a customer, I want to confirm identity for large transfers." -AC "Given transfer > 500, Then MFA challenge`nGiven MFA verified, Then 5-min elevated session" -SP 5 -Pri 1 -Tags "step-up" -ParentId 266
New-US -Title "Fraud velocity checks" -Desc "As a risk officer, I want velocity checks on transfers." -AC "Given > 5 transfers in 10 min, Then 6th blocked + alert`nGiven 3+ velocity blocks in 24h, Then manual review" -SP 8 -Pri 1 -Tags "fraud" -ParentId 266
New-US -Title "Transfer confirmation and receipt" -Desc "As a customer, I want confirmation and receipt after transfers." -AC "Given success, Then confirmation screen + email receipt" -SP 3 -Pri 2 -Tags "receipt" -ParentId 266

# Feature 267: Transfer History
New-US -Title "Transfer history and search" -Desc "As a customer, I want to view and search transfer history." -AC "Given history page, Then all transfers listed with status filter`nGiven export, Then CSV download" -SP 5 -Pri 3 -Tags "history" -ParentId 267

# Feature 269: One-Time Payments
Write-Host "Bill Pay (F269-F271)" -ForegroundColor Cyan
New-US -Title "Pay a bill from any linked account" -Desc "As a customer, I want to pay bills from any of my accounts." -AC "Given biller and amount, Then choose source account`nGiven success, Then confirmation with delivery date" -SP 5 -Pri 1 -Tags "bill-pay" -ParentId 269
New-US -Title "Biller directory search and add" -Desc "As a customer, I want to find and add billers." -AC "Given search term, Then typeahead suggestions after 2 chars`nGiven custom biller, Then manual entry form" -SP 5 -Pri 2 -Tags "billers" -ParentId 269
New-US -Title "Payment confirmation with expected delivery date" -Desc "As a customer, I want to know when my bill payment will arrive." -AC "Given payment submitted, Then show expected delivery (2-5 business days)" -SP 3 -Pri 2 -Tags "confirmation" -ParentId 269

# Feature 270: Scheduled Payments
New-US -Title "Recurring bill payment setup" -Desc "As a customer, I want to set up automatic recurring payments." -AC "Given recurring setup, Then select frequency (weekly/biweekly/monthly)`nGiven start date, Then first payment scheduled" -SP 8 -Pri 1 -Tags "recurring" -ParentId 270
New-US -Title "Edit or cancel scheduled payment" -Desc "As a customer, I want to modify or cancel scheduled payments." -AC "Given editing, Then change amount, date, account, frequency`nGiven cancel, Then confirmation dialog" -SP 5 -Pri 2 -Tags "scheduled" -ParentId 270
New-US -Title "Skip a single occurrence" -Desc "As a customer, I want to skip one payment in a recurring series." -AC "Given skip requested, Then that occurrence skipped`nGiven next occurrence, Then resumes normally" -SP 5 -Pri 3 -Tags "skip" -ParentId 270

# Feature 271: Payment Tracking
New-US -Title "Bill payment history" -Desc "As a customer, I want to view my bill payment history." -AC "Given history page, Then all payments listed with biller, amount, date, status" -SP 3 -Pri 3 -Tags "history" -ParentId 271
New-US -Title "E-bill and paperless statements" -Desc "As a customer, I want to receive e-bills and go paperless." -AC "Given supported biller, Then e-bill in dashboard`nGiven paperless opt-in, Then paper stopped" -SP 3 -Pri 3 -Tags "e-bill" -ParentId 271

# Feature 273: Support Ticket System
Write-Host "Support (F273-F275)" -ForegroundColor Cyan
New-US -Title "Create support ticket" -Desc "As a customer, I want to create a support ticket." -AC "Given creation form, Then select category, priority, description`nGiven submission, Then ticket number assigned" -SP 5 -Pri 1 -Tags "tickets" -ParentId 273
New-US -Title "Track ticket status" -Desc "As a customer, I want to track my ticket status." -AC "Given ticket list, Then status badges (Open, In Progress, Waiting, Resolved, Closed)" -SP 3 -Pri 2 -Tags "status" -ParentId 273
New-US -Title "Add comments and attachments to tickets" -Desc "As a customer, I want to add context to my support tickets." -AC "Given open ticket, Then add comment and attachments (< 10MB)" -SP 5 -Pri 2 -Tags "comments" -ParentId 273
New-US -Title "Reopen resolved ticket" -Desc "As a customer, I want to reopen a resolved ticket if my issue persists." -AC "Given resolved < 7 days, Then Reopen button available`nGiven reopened, Then status returns to Open" -SP 3 -Pri 3 -Tags "reopen" -ParentId 273

# Feature 274: Transaction Disputes
New-US -Title "File a transaction dispute" -Desc "As a customer, I want to dispute a transaction." -AC "Given any transaction, Then Dispute button`nGiven filed, Then estimated resolution date shown (10 days)" -SP 8 -Pri 1 -Tags "disputes" -ParentId 274
New-US -Title "Provisional credit for disputes" -Desc "As a customer, I want provisional credit while my dispute is investigated." -AC "Given eligible dispute > 2 days, Then provisional credit applied" -SP 5 -Pri 1 -Tags "provisional-credit" -ParentId 274
New-US -Title "Dispute resolution notification" -Desc "As a customer, I want to know when my dispute is resolved." -AC "Given resolution, Then email and in-app notification`nGiven denied, Then provisional credit reversed with 3-day notice" -SP 3 -Pri 2 -Tags "notification" -ParentId 274

# Feature 275: Secure Messaging
New-US -Title "Secure messaging with support" -Desc "As a customer, I want to message support securely." -AC "Given messaging, Then messages encrypted end-to-end`nGiven new reply, Then notification sent" -SP 5 -Pri 3 -Tags "messaging" -ParentId 275
New-US -Title "Message history and search" -Desc "As a customer, I want to search through my message history." -AC "Given inbox, Then all conversations listed`nGiven search, Then keyword search across messages" -SP 3 -Pri 3 -Tags "search" -ParentId 275

# Feature 277: Document Upload
Write-Host "Documents (F277-F279)" -ForegroundColor Cyan
New-US -Title "Upload documents (PDF, JPG)" -Desc "As a customer, I want to upload documents for my account." -AC "Given upload, Then PDF and JPG accepted (< 10MB)`nGiven upload, Then virus scan before storage" -SP 5 -Pri 2 -Tags "upload" -ParentId 277
New-US -Title "Document categorization" -Desc "As a customer, I want my documents organized by category." -AC "Given upload, Then select category (Identification, Statements, Tax, Correspondence)" -SP 3 -Pri 3 -Tags "categories" -ParentId 277

# Feature 278: Document Viewing
New-US -Title "Document library with preview" -Desc "As a customer, I want to browse and preview my documents." -AC "Given library, Then thumbnails with name, date, category`nGiven click, Then in-browser preview" -SP 5 -Pri 2 -Tags "preview" -ParentId 278
New-US -Title "Document search" -Desc "As a customer, I want to find specific documents." -AC "Given search, Then keyword search across names and categories" -SP 3 -Pri 3 -Tags "search" -ParentId 278
New-US -Title "Delete documents" -Desc "As a customer, I want to delete my uploaded documents." -AC "Given delete, Then confirmation dialog`nGiven bank-required docs, Then delete disabled" -SP 3 -Pri 3 -Tags "delete" -ParentId 278

# Feature 279: E-Statements
New-US -Title "Monthly e-statement generation" -Desc "As a customer, I want to receive monthly e-statements." -AC "Given month end, Then e-statement generated and available`nGiven retention, Then 7 years available" -SP 5 -Pri 2 -Tags "statements" -ParentId 279
New-US -Title "E-statement opt-in and preferences" -Desc "As a customer, I want to manage my statement preferences." -AC "Given preferences, Then choose paperless or paper" -SP 3 -Pri 3 -Tags "preferences" -ParentId 279

# Feature 281: Notification Center
Write-Host "Notifications (F281-F283)" -ForegroundColor Cyan
New-US -Title "In-app notification bell" -Desc "As a customer, I want to see notifications in the app." -AC "Given notifications, Then bell icon shows unread count`nGiven click, Then dropdown with grouped notifications" -SP 5 -Pri 1 -Tags "bell" -ParentId 281
New-US -Title "Notification grouping and actions" -Desc "As a customer, I want notifications grouped and actionable." -AC "Given grouping, Then by type (security, transactions, support)`nGiven click, Then navigate to relevant screen" -SP 5 -Pri 2 -Tags "grouping" -ParentId 281
New-US -Title "Notification history (90 days)" -Desc "As a customer, I want to review past notifications." -AC "Given notification page, Then 90-day history`nGiven filter, Then by type and read/unread" -SP 3 -Pri 3 -Tags "history" -ParentId 281

# Feature 282: Alert Configuration
New-US -Title "Custom balance alerts" -Desc "As a customer, I want alerts when balance drops below a threshold." -AC "Given alert configured, Then notify when balance < threshold`nGiven channel, Then choose email, SMS, push, or in-app" -SP 5 -Pri 1 -Tags "alerts; balance" -ParentId 282
New-US -Title "Transaction amount alerts" -Desc "As a customer, I want alerts for large transactions." -AC "Given alert configured, Then notify when transaction > threshold" -SP 5 -Pri 2 -Tags "alerts; transactions" -ParentId 282
New-US -Title "Security event notifications" -Desc "As a customer, I want to be notified of security events." -AC "Given login from new device, Then immediate notification`nGiven password change, Then confirmation sent" -SP 3 -Pri 1 -Tags "security; mandatory" -ParentId 282

# Feature 283: Notification Preferences
New-US -Title "Notification preferences management" -Desc "As a customer, I want to control which notifications I receive." -AC "Given preferences page, Then matrix of notification types vs channels`nGiven security notifications, Then cannot be disabled" -SP 5 -Pri 2 -Tags "preferences" -ParentId 283
New-US -Title "Quiet hours configuration" -Desc "As a customer, I want to set quiet hours for non-urgent notifications." -AC "Given quiet hours set, Then non-urgent held until morning`nGiven security alerts, Then always delivered immediately" -SP 3 -Pri 3 -Tags "quiet-hours" -ParentId 283

Write-Host "`n=== COMPLETE ===" -ForegroundColor Yellow
Write-Host "Created: $created stories" -ForegroundColor Green
Write-Host "Failed:  $failed stories" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
