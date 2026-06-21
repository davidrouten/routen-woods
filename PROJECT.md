# Routen Woods — Project Tracker

## Phase 1: Bootstrap
- [x] Rails 8 new with PostgreSQL + Tailwind
- [x] Gemfile: devise, pagy, twilio-ruby, slack-notifier, simple_form, faker, dotenv, letter_opener, annotate
- [x] /docs directory
- [x] PROJECT.md
- [x] .env.example
- [x] Git init + initial commit

## Phase 2: Core Models & Auth
- [x] Devise install + User model (admin boolean, first_name, last_name, phone)
- [x] Permission model (resource + action)
- [x] UserPermission join table
- [x] User#can?(action, resource) helper
- [x] Lead model (status enum, UTM, spam_score, temperature, honeypot, timing)
- [x] Note model (belongs_to lead + user)
- [x] StatusChange model (audit log)
- [x] NotificationPreference model (event → channel toggles)
- [x] Testimonial model
- [x] GalleryImage model (Active Storage)
- [x] Migrations + db:create + db:migrate

## Phase 3: Service Layer
- [x] SalesEngine facade + InternalAdapter
- [x] NotificationService + Notifiers::EmailNotifier
- [x] Notifiers::SmsNotifier
- [x] Notifiers::SlackNotifier
- [x] SpamDetector (honeypot, timing, email patterns, spam words, dupes)
- [x] LeadScorer (completeness, service value, engagement)

## Phase 4: i18n & Marketing Site
- [x] config/locales/business.en.yml (all white-label content)
- [x] config/locales/notifications.en.yml
- [x] Public layout (sticky header, footer, floating CTA, exit-intent)
- [x] Landing page: hero section (full-viewport, gradient, angled dividers)
- [x] Landing page: trust bar (experience, projects, rating, guarantee)
- [x] Landing page: services grid (hover animations, accent lines)
- [x] Landing page: process steps (4-step with connecting line)
- [x] Landing page: testimonials (dark bg, backdrop blur cards, author avatars)
- [x] Landing page: gallery preview
- [x] Landing page: about/values section
- [x] Landing page: contact section (3/5 split with info sidebar)
- [x] Quick quote form (name, phone, email, service dropdown)
- [x] Inline CTAs (dual CTA with phone + quote)
- [x] SEO meta tags from i18n
- [x] Services page (alternating layout)
- [x] About page
- [x] Gallery page
- [x] Contact page

## Phase 5: Admin Backend
- [x] Admin::BaseController with auth + permission checks
- [x] Admin::DashboardController (leads by status, recent, hot)
- [x] Admin::LeadsController (index, show, transition, mark_spam, assign)
- [x] Admin::NotesController (create, destroy via Turbo Stream)
- [x] Admin layout (sidebar nav with user avatar)
- [x] Lead index: filterable table with status/temp badges + search
- [x] Lead show: detail + notes timeline + status history + UTM data
- [x] Spam view (filtered leads)
- [x] Notification preferences UI
- [x] Testimonials CRUD
- [x] Gallery CRUD (with image upload)

## Phase 6: Polish & Deploy
- [x] Stimulus: form_timing_controller (spam detection)
- [x] Stimulus: exit_intent_controller
- [x] Stimulus: floating_cta_controller (desktop quote + mobile pulsing phone)
- [x] Stimulus: mobile_menu_controller
- [x] Stimulus: dismissable_controller (flash messages)
- [x] NotificationMailer templates
- [x] SmsNotificationJob
- [x] SlackNotificationJob
- [x] Seeds (admin user, sample leads, testimonials — Oxford, MI area)
- [x] Responsive design pass
- [x] Tailwind theme (navy, amber, warm whites, gradient overlays, angled dividers)
- [x] RSpec test suite (95 specs — models, services, requests, turnstile)
- [x] Heroku deployment (Procfile, single-dyno config, async jobs, memory cache)
- [x] AWS S3 for image uploads (production bucket: routen-woods-production, IAM scoped)
- [x] SSL + force_ssl enabled

## Phase 7: Hardening & Performance (In Progress)
- [x] Cloudflare Turnstile on lead forms (soft signal, not hard block — weight 0.5 in SpamDetector)
- [x] Image optimization: lazy loading, decoding="async", fetchpriority="high" on LCP image
- [x] Image optimization: Active Storage variants (resized webp) for gallery images
- [x] Spam score column in admin leads index (color-coded progress bar)
- [X] Heroku libvips buildpack for production image variants
- [x] Gallery lightbox (click image to view full-size, keyboard nav, Stimulus controller)
- [ ] Rate limiting by IP (add as SpamDetector signal)
- [ ] Production email delivery (SendGrid / Postmark)
- [ ] Twilio SMS setup (env vars)
- [ ] Slack webhook setup (env vars)
- [ ] Real business content (photos, address, phone, email)
- [ ] Admin password change from default
- [ ] Custom domain + DNS

## Phase 8: Admin Improvements (In Progress)

### 8.1 — "Open" filter & default
- [x] Add "Open" filter to leads index (all non-closed/spam/archived leads)
- [x] Default leads index to "Open" filter on page load

### 8.2 — Soft delete / archive leads
- [x] Add `archived_at` column to leads (soft delete)
- [x] Archive button on each lead row with modal confirmation
- [x] Archived leads excluded from "Open" filter
- [x] "Archived" view to see/restore archived leads

### 8.3 — Custom confirmation modal (Stimulus)
- [x] Branded modal component (replaces browser confirm dialogs)
- [x] Replace all turbo_confirm dialogs with custom modal
- [x] Inline status change from leads index via modal (pill menu)
- [x] Spam button uses custom modal
- [x] Status change triggers Turbo Stream in-place update (no full page reload)

### 8.4 — Lead Form Enhancement (COMPLETE)
- [x] Migration: added `budget_range`, `timeframe`, `services_interested_in` (PG array), `zip_code` to leads
- [x] Migrated existing `service_interested_in` (singular) data into array, removed old column
- [x] i18n: budget_ranges (5 tiers: Under $5k through $20k+) and timeframes (ASAP through Just planning)
- [x] Form: replaced service dropdown with checkboxes, added budget/timeframe dropdowns, zip code field
- [x] Lead scorer: budget scoring (+0 to +15) and timeframe scoring (+0 to +20)
- [x] Admin index: replaced Service column with Budget + Timeframe columns
- [x] Admin show: added budget, timeframe, zip code, services as pill badges
- [x] Updated all notifiers, mailers, dashboard to use `services_interested_in` (array)
- [x] Updated factory, seeds, and all specs (97 passing)

## Phase 8.5: Design System & Styling Revamp (COMPLETE)

Goal: eliminate all 180+ hardcoded hex values (`#d4a338`, `#0f1b2d`, etc.) from templates. Establish a proper design system with semantic tokens so color/style changes happen in ONE place.

### 8.5.1 — Theme colors (`theme.css`)
- [x] Created `app/assets/tailwind/theme.css` with `@theme` block
- [x] 5 semantic color tokens: `primary` (#0f1b2d), `primary-light` (#1b2a4a), `primary-dark` (#0a1220), `accent` (#d4a338), `accent-hover` (#b8860b)
- [x] All utilities auto-generated: `bg-primary`, `text-accent`, `border-accent/20`, etc.

### 8.5.2 — Component classes (`components.css`)
- [x] Created `app/assets/tailwind/components.css` with 13 reusable classes:
  - Buttons: `.btn-primary`, `.btn-primary-sm`, `.btn-outline`, `.btn-admin`, `.btn-admin-link`
  - Inputs: `.input`, `.input-admin`
  - Headings: `.section-label`, `.section-heading`
  - Layout: `.bg-brand-gradient`, `.glow-orb`, `.accent-bar`, `.avatar-accent`, `.icon-box`, `.icon-box-accent`

### 8.5.3 — Migration (30 ERB files, 180+ hex references)
- [x] Replaced all hardcoded hex values across all 30 ERB templates
- [x] Applied component classes to reduce template verbosity
- [x] Updated `application.css` entry point to import theme + components
- [x] Zero hardcoded hex values remain in any template
- [x] Tailwind builds clean with all tokens and components

### Architecture
- Entry point: `app/assets/tailwind/application.css` → imports `theme.css` + `components.css`
- To re-theme: change 5 hex values in `theme.css`, everything updates automatically
- Component classes use `@apply` to compose Tailwind utilities into reusable patterns

## Phase 9: SEO, Speed & Structured Data

### 9.1 — JSON-LD structured data
- [x] LocalBusiness schema (service-area business, working hours, geo, cities served)
- [x] Service schema (one per service offering with description, price-from ranges)
- [x] FAQPage schema on home page (5 questions from i18n)
- [x] Inject via layout helper, all sourced from business.en.yml
- [x] Gated behind ENABLE_STRUCTURED_DATA env var (off until go-live)

### 9.2 — Performance / CDN
- [x] Responsive srcset (400w mobile, 800w desktop) via helper
- [x] Heroku libvips buildpack (already added)

### 9.3 — Before/after photo component
- [ ] Before/after slider component (Stimulus controller)
- [ ] Organize gallery by style/category (white shaker, stained oak, painted island, etc.)
- [ ] GalleryImage: add category and before/after pairing fields

### 9.4 — Dedicated service pages
- [ ] One page per service offering (not one bloated page)
- [ ] Each page: what's included, rough price range, timeline, service area, reviews
- [ ] Inline testimonials on service pages (not quarantined on testimonials page)

---

# Two Pipelines: Lead → Project

The system has two distinct lifecycles. A **Lead** is a sales conversation — someone expressed interest, we reach out, we negotiate, and either win or lose the deal. A **Project** is a job — it exists only after a lead is won, and tracks planning through completion and payment. One lead can spawn multiple projects (e.g. seven franchise locations), but the models stay separate because the concerns are different: leads care about speed-to-contact and qualification; projects care about scheduling, photos, client communication, and getting paid.

### Design principle: compound actions

Status should never be a chore. Every status transition is a **side effect of the real-world action** the user was going to take anyway. The "Call" button is a `tel:` link that also stamps `contacted_at`. "Mark complete" also fires the balance payment link and the review request. One tap, multiple effects, defined in one place (AASM callbacks or guarded transition methods on the model).

### Design principle: one primary action per state

Each state surfaces exactly one big obvious button — the most likely next step. Everything else (edit cost, add a note) is inline and secondary. The user never has to decide "what do I do next?" — the card tells them.

### Lead states
```
new → contacted → negotiating → won | lost
```
- **New**: primary action = Call/Text (tel: link + stamps contacted_at)
- **Contacted**: primary action = Mark Negotiating (they're interested, working on scope/price)
- **Negotiating**: primary action = Won (creates Project) or Lost (closes with reason)
- **Won**: lead is closed, project(s) created — lead becomes read-only history
- **Lost**: closed with lost_reason, available for re-engagement later

### Project states
```
scheduled → in_progress → complete → paid
                ↕
             blocked
```
- **Scheduled**: primary action = Add Details (scope, price, dates) — triggers deposit link + client page goes live
- **In Progress**: primary action = Post Update (photo/note) — syncs to client page automatically
- **Blocked**: reachable from in_progress, returns to in_progress when resolved — surfaces "what's blocking?" prominently
- **Complete**: primary action = Request Balance + Review — sends balance payment link + review ask via SMS
- **Paid**: terminal — auto-set by Stripe webhook, updates client page, job is done

---

## Phase 10: Lead Pipeline Refinement (NOT STARTED)

Refine the existing Lead model to be a clean sales pipeline. Lead's job ends at won/lost — it should NOT track project execution.

### 10.1 — Lead state machine cleanup
- [ ] Refine Lead status enum: `new`, `contacted`, `negotiating`, `won`, `lost`
- [ ] Remove any project-execution statuses from Lead (booked, in_progress, completed — these belong on Project)
- [ ] Add `contacted_at` timestamp (set automatically when status → contacted)
- [ ] Add `lost_reason` field (free text, set when status → lost)
- [ ] AASM or guarded transitions with callbacks (e.g. `lead.contact!` stamps contacted_at + notifies)
- [ ] Migrate existing leads to new status values

### 10.2 — Speed-to-lead
- [ ] Instant push/SMS to owner on new lead (partially wired — needs Twilio/SendGrid setup)
- [ ] "Contacted?" timer on lead cards — shows elapsed time since created_at
- [ ] Lead aging visual (highlight leads not contacted within configurable threshold)
- [ ] New lead sound/vibration on admin (via push notification)

### 10.3 — Compound actions on lead cards
- [ ] "Call" button = `tel:` link + auto-stamps `contacted_at` in same tap
- [ ] "Text" button = `sms:` link + auto-stamps `contacted_at`
- [ ] "Won" action = transitions lead + opens "Create Project" flow in one step
- [ ] "Lost" action = modal for lost_reason + closes lead
- [ ] One primary action button per state, prominent on the card — everything else secondary

### 10.4 — Form qualification
- [ ] ZIP code field with service-area gate (warn if outside area, still accept)
- [ ] Photo upload on lead form (Active Storage, opens camera on mobile)
- [ ] Kitchen size / scope field
- [ ] TCPA opt-in consent checkbox + language (required if SMS enabled)
- [ ] Consent tracking: inquiry consent vs marketing opt-in, with timestamps

## Phase 11: Project Model & Execution Pipeline (NOT STARTED)

Project is a separate model from Lead. It represents a confirmed job moving through execution to payment.

### 11.1 — Project model
- [ ] Project model: `belongs_to :lead`, `has_many :project_photos`, `has_many :messages`
- [ ] Fields: title, description, address, estimated_price, deposit_amount, balance_amount, estimated_duration_days, scheduled_start_date, scheduled_end_date
- [ ] Status enum via AASM: `scheduled`, `in_progress`, `blocked`, `complete`, `paid`
- [ ] `has_secure_token :client_token` — stable, revocable token for magic-link client page
- [ ] Each transition owns its side effects via callbacks (see compound actions principle above)
- [ ] Testimonial optionally `belongs_to :project` (link reviews to specific jobs)

### 11.2 — Lead → Project conversion
- [ ] "Won" on a lead opens a quick-create Project form (prefilled from lead details)
- [ ] Lead status auto-set to `won` when project is created
- [ ] One lead can create multiple projects (e.g. multi-site franchise jobs)
- [ ] Lead becomes read-only history once won — all further work happens on the Project
- [ ] Project links back to originating lead for audit trail

### 11.3 — Compound actions on project cards
- [ ] **Scheduled**: "Add Details" — inline edit scope/price/dates, triggers deposit payment link generation
- [ ] **In Progress**: "Post Update" — photo upload (camera-native on mobile) + optional note, auto-syncs to client page
- [ ] **Blocked**: "What's blocking?" — prominent text field, returns to in_progress when resolved
- [ ] **Complete**: "Request Payment" — generates balance payment link + sends review request (single tap, both fire)
- [ ] **Paid**: no action needed — auto-set by Stripe webhook

### 11.4 — Project photos
- [ ] ProjectPhoto model (Active Storage, belongs_to :project)
- [ ] Before/after tagging (enum: before, during, after)
- [ ] Camera-native upload on mobile (accept="image/*" capture="environment")
- [ ] Photos auto-appear on client status page
- [ ] Optional: promote project photos to public gallery

### 11.5 — Job-type templates (later)
- [ ] Predefined templates: "$5k cabinet refresh", "full refinish + pull-outs", etc.
- [ ] Templates prefill line items, typical price band, estimated duration
- [ ] "Add details" becomes mostly confirming, not typing from scratch

## Phase 12: Client Status Page (NOT STARTED)

Each project gets a public, tokenized URL that clients can visit to see their job's status, photos, pay, and communicate — no login required. This is high-leverage because updating the project for the shop also updates what the client sees. Two tasks become one.

### 12.1 — Magic-link client page
- [ ] Route: `GET /p/:client_token` — looks up project by `has_secure_token`
- [ ] No login required — token is unguessable, can be revoked if needed
- [ ] Read-only view: project status, timeline, photos, next steps
- [ ] Status-aware content: shows different messaging per state (e.g. "Your cabinets are being refinished" vs "Work is complete — here's your invoice")
- [ ] SMS sent to client on key state changes with the magic link ("Your cabinets are in finishing — here's the latest")

### 12.2 — Client messaging thread
- [ ] Message model: `belongs_to :project`, `sender` enum (`client`, `shop`)
- [ ] Client can post messages from the status page (textarea, rate-limited, HTML-escaped)
- [ ] Messages are immutable + timestamped (paper trail for scope disputes)
- [ ] Auto-acknowledgment on submit: "Got it — Ryan will see this and follow up"
- [ ] Inbound client messages push/SMS to shop immediately (speed-to-lead treatment)
- [ ] `acknowledged_at` on client messages — shop taps to acknowledge, clears "needs attention" badge
- [ ] `project.messages.unresolved.any?` drives badge on active project cards
- [ ] Shop replies go back out as SMS to client (they don't need to refresh the page)

### 12.3 — Guardrails
- [ ] Rate-limit message submissions from client page
- [ ] Never render client input as raw HTML (ERB auto-escapes, but avoid `raw`/`html_safe`)
- [ ] Token expiry or revocation mechanism if needed

## Phase 13: Payments via Stripe (NOT STARTED)

Build almost nothing — lean on Stripe to generate payment links and a webhook to close the loop. No invoicing UI, no payment reconciliation. Use ACH for large payments to avoid getting eaten alive by card processing fees.

### Fee strategy
- **Card payments (2.9% + $0.30)**: fine for small deposits, but $145 on a $5k balance and $725 on $25k is unacceptable
- **ACH bank transfer (0.8%, capped at $5)**: use for balance payments — $5 flat on any job size
- **Rule of thumb**: offer card for deposits (convenience, smaller amounts), default to ACH for balance payments (large amounts, $5 cap saves hundreds)
- **Optional**: pass card processing fee through as a "convenience fee" if client insists on card for balance — common in contracting

### 13.1 — Stripe integration
- [ ] Stripe gem (`stripe` + `stripe-rails`) + API keys in env
- [ ] Generate deposit Payment Link when project enters `scheduled` (card payment, amount from `deposit_amount`)
- [ ] Generate balance Payment Link when project enters `complete` (ACH preferred, card as fallback, amount from `balance_amount`)
- [ ] Client status page shows both payment options with clear fee disclosure ("Pay by bank transfer — no fee" vs "Pay by card — 3% convenience fee")
- [ ] Both links appear on client status page + get texted to client
- [ ] Single webhook endpoint: `checkout.session.completed` / `payment_intent.succeeded` → `project.mark_paid!`
- [ ] `mark_paid!` callback updates client page status to "Paid — thank you!"
- [ ] Payment model for audit: amount, stripe_payment_id, paid_at, payment_type (deposit/balance), payment_method (card/ach)

### 13.2 — Payment visibility
- [ ] Admin project card shows payment status (deposit paid? balance paid? method used?)
- [ ] Client page shows what's owed and pay button(s)
- [ ] Stripe handles receipts and reminders — we don't build that

### 13.3 — Fee reference
| Method | Rate | $500 deposit | $5k balance | $25k balance |
|--------|------|-------------|-------------|--------------|
| Card | 2.9% + $0.30 | $14.80 | $145.30 | $725.30 |
| ACH | 0.8% ($5 cap) | $4.00 | $5.00 | $5.00 |

## Phase 14: PWA & Mobile-First Admin (NOT STARTED)

The admin "portal" is really a phone app wearing a web page's clothes. Build it phone-first because the user is on a jobsite, not at a desk.

### 14.1 — PWA setup
- [ ] Web app manifest (name, icons, theme color, display: standalone)
- [ ] Service worker for offline fallback + caching
- [ ] "Add to home screen" prompt
- [ ] PWA lives on home screen, launches without browser chrome

### 14.2 — Push notifications
- [ ] Web Push API for new leads (speed-to-lead — must know within seconds)
- [ ] Push for new client messages (inbound messages get speed-to-lead treatment)
- [ ] Push on payment received
- [ ] Fallback to SMS if push not available

### 14.3 — Mobile-first admin UX
- [ ] Thumb-reachable primary action buttons (bottom of card, not top)
- [ ] Camera-native photo upload (`capture="environment"` — opens camera, not file picker)
- [ ] Voice-to-text for notes (Web Speech API — dictate measurements with dust on your hands)
- [ ] Swipe gestures for common actions (swipe right = advance status)
- [ ] Optimistic UI — tap registers instantly, syncs in background

## Phase 15: AI Features (NOT STARTED)

### 15.1 — Unstructured text → Lead
- [ ] Input box in admin: paste/type unstructured text about a call, meeting, referral
- [ ] LLM parses out: name, phone, email, address, service interest, notes, price discussed
- [ ] Preview parsed result, highlight missing info, let user confirm/edit before creating
- [ ] Auto-creates lead with contact details + adds parsed notes
- [ ] Example: "just got off the phone with Jon Smith, 813-444-5555, wants to refinish 14 cabinets, walnut veneer, gold pulls, ~$7500 estimate"

### 15.2 — SMS-to-lead
- [ ] User texts unstructured details to a Twilio number → system auto-creates lead
- [ ] Confirmation reply back to user with parsed summary
- [ ] Same parsing pipeline as 15.1

### 15.3 — Conversational assistant
- [ ] LLM with access to leads, projects, calendar data
- [ ] Ask questions: "what's the cell number for the Reynolds job?"
- [ ] Ask for summaries: "what work do we have going on this week?"
- [ ] Available via admin chat panel and SMS

## Phase 16: Scheduling & Multi-Project (NOT STARTED)

### 16.1 — Project calendar
- [ ] Calendar/timeline view of projects by week
- [ ] Estimated duration per project (from project fields)
- [ ] Crew/person assignment per project
- [ ] Uncertainty overlap visualization (dotted lines, ~20-30% beyond estimated end)
- [ ] "Booked X weeks out" dashboard indicator

### 16.2 — GroupProject (multi-site jobs)
- [ ] GroupProject model: ties multiple Projects together under one umbrella
- [ ] Use case: client wants to refinish 7 franchise locations — one lead, one group, 7 projects
- [ ] Group-level status rollup (all scheduled? any blocked? all paid?)
- [ ] Single client page for the group with per-location status
- [ ] Not needed until the use case actually appears — build it then

## Phase 17: Permissions & User-Specific Settings (NOT STARTED)

### 17.1 — Granular permissions
- [ ] Define permission scopes: `manage:leads`, `manage:projects`, `manage:testimonials`, `manage:gallery`, `manage:settings`
- [ ] Audit existing `require_permission!` calls and align with new scopes
- [ ] Admin UI for assigning permissions per user (checklist on user edit page)
- [ ] Named role templates (e.g. "Sales" = leads only, "Content" = testimonials + gallery, "Full Access" = everything)

### 17.2 — User-specific notification preferences
- [ ] Move notification prefs from app-wide to per-user (each user controls their own channels)
- [ ] Keep existing app-wide prefs as defaults for new users
- [ ] User settings page: "My Notifications" — toggle email/sms/slack per event
- [ ] Only deliver to users who have the relevant permission AND have that channel enabled
- [ ] Example: team member with `manage:leads` gets new_lead notifications; content person does not

## Future / Backlog
- [ ] CloudFront CDN in front of S3 (needed at 100+ images)
- [ ] Long cache headers on image assets (revisit with CloudFront)
- [ ] Background job to pre-process image variants on upload (eliminates cold-start delay)
- [ ] AWS S3 dev/staging bucket for local development
- [ ] Stimulus: lead_filter_controller (dynamic admin filtering)
- [ ] AI-powered lead scoring (LLM integration)
- [ ] HubSpot adapter for SalesEngine
- [ ] Salesforce adapter for SalesEngine
- [ ] Multi-tenant support
- [ ] Analytics dashboard (conversion rates, lead sources, win/loss ratios)
- [ ] Email drip campaigns for lost leads (re-engagement)
- [ ] Review/reputation management (aggregate Google reviews)
- [ ] Google Analytics / SEO sitemap
- [ ] Extract Contact/Person from Lead (same person → multiple leads → multiple projects) — not needed at first
- [ ] Before/after slider component for gallery (Stimulus controller)
- [ ] Dedicated service pages (one per offering, with inline testimonials)
- [ ] Surface pricing signals when demand exceeds capacity
