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
- [ ] Heroku libvips buildpack for production image variants
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

### 8.4 — Dynamic services CRUD
- [ ] Service model (name, description, active boolean)
- [ ] Admin CRUD for services (Lead Generation Settings page)
- [ ] Lead form: multi-select for services (checkboxes if ≤6, else dropdown)
- [ ] Inline edit services via modal on leads index

### 8.5 — Budget range options
- [ ] BudgetRange model (label, active boolean, sort_order)
- [ ] Admin CRUD on Lead Generation Settings page
- [ ] Lead form: budget range dropdown (active options only)
- [ ] Inline edit budget via modal on leads index

### 8.6 — Timeframe options
- [ ] Timeframe model (label, active boolean, sort_order)
- [ ] Admin CRUD on Lead Generation Settings page
- [ ] Lead form: timeframe dropdown (active options only)
- [ ] Inline edit timeframe via modal on leads index
- [ ] Default options: ASAP, 1-4 weeks, 2-3 months, 3-6 months, Just browsing

### 8.7 — LeadFormSettings (HOLD — needs more planning)
- [ ] LeadFormSettings object to track multiple form configurations
- [ ] Setting to determine which forms display where in the app
- [ ] Per-form field requirements (e.g. budget optional, timeframe required)
- [ ] Field customization per form (A/B testing, seasonal promos)

## Future / Backlog
- [ ] AWS S3 dev/staging bucket for local development
- [ ] Stimulus: lead_filter_controller (dynamic admin filtering)
- [ ] AI-powered lead scoring (LLM integration)
- [ ] Push notifications
- [ ] HubSpot adapter for SalesEngine
- [ ] Salesforce adapter for SalesEngine
- [ ] Named permission sets / "role templates"
- [ ] Multi-tenant support
- [ ] Analytics dashboard (conversion rates, lead sources)
- [ ] Email drip campaigns
- [ ] Online scheduling / calendar integration
- [ ] Review/reputation management
- [ ] Google Analytics / SEO sitemap
