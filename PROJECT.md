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
- [x] RSpec test suite (85 specs — models, services, requests)
- [x] Heroku deployment (Procfile, single-dyno config, async jobs, memory cache)
- [x] AWS S3 for image uploads (production bucket: routen-woods-production, IAM scoped)
- [x] SSL + force_ssl enabled

## Phase 7: Hardening (In Progress)
- [ ] Cloudflare Turnstile on lead forms (soft signal, not hard block — weight 0.5 in SpamDetector)
- [ ] Rate limiting by IP (add as SpamDetector signal)
- [ ] Production email delivery (SendGrid / Postmark)
- [ ] Twilio SMS setup (env vars)
- [ ] Slack webhook setup (env vars)
- [ ] Real business content (photos, address, phone, email)
- [ ] Admin password change from default
- [ ] Custom domain + DNS

## Future / Backlog
- [ ] AWS S3 dev/staging bucket for local development
- [ ] Stimulus: gallery_lightbox_controller
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
