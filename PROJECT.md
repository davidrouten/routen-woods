# Routen Woods — Project Tracker

## Phase 1: Bootstrap
- [x] Rails 8 new with PostgreSQL + Tailwind
- [x] Gemfile: devise, pagy, twilio-ruby, slack-notifier, simple_form, faker, dotenv, letter_opener, annotate
- [x] /docs directory
- [x] PROJECT.md
- [ ] .env.example
- [ ] Git init + initial commit

## Phase 2: Core Models & Auth
- [ ] Devise install + User model (admin boolean, first_name, last_name, phone)
- [ ] Permission model (resource + action)
- [ ] UserPermission join table
- [ ] User#can?(action, resource) helper
- [ ] Lead model (status enum, UTM, spam_score, temperature, honeypot, timing)
- [ ] Note model (belongs_to lead + user)
- [ ] StatusChange model (audit log)
- [ ] NotificationPreference model (event → channel toggles)
- [ ] Testimonial model
- [ ] GalleryImage model (Active Storage)
- [ ] Migrations + db:create + db:migrate

## Phase 3: Service Layer
- [ ] SalesEngine facade + InternalAdapter
- [ ] NotificationService + Notifiers::EmailNotifier
- [ ] Notifiers::SmsNotifier
- [ ] Notifiers::SlackNotifier
- [ ] SpamDetector (honeypot, timing, email patterns, spam words, dupes)
- [ ] LeadScorer (completeness, service value, engagement)

## Phase 4: i18n & Marketing Site
- [ ] config/locales/business.en.yml (all white-label content)
- [ ] config/locales/notifications.en.yml
- [ ] Public layout (sticky header, footer, floating CTA, exit-intent)
- [ ] Landing page: hero section
- [ ] Landing page: services grid
- [ ] Landing page: testimonials
- [ ] Landing page: gallery preview
- [ ] Landing page: about/values section
- [ ] Landing page: contact section
- [ ] Quick quote form (name, phone, email, service dropdown)
- [ ] Detailed contact form
- [ ] Inline CTAs after value sections
- [ ] SEO meta tags from i18n

## Phase 5: Admin Backend
- [ ] Admin::BaseController with auth + permission checks
- [ ] Admin::DashboardController (leads by status, recent, hot)
- [ ] Admin::LeadsController (index, show, transition, mark_spam, assign)
- [ ] Admin::NotesController (create, destroy via Turbo Stream)
- [ ] Admin layout (sidebar nav, top bar)
- [ ] Lead index: filterable table with status/temp badges
- [ ] Lead show: detail + notes timeline + status history
- [ ] Spam view (filtered leads)
- [ ] Notification preferences UI
- [ ] Testimonials CRUD
- [ ] Gallery CRUD

## Phase 6: Polish
- [ ] Stimulus: form_timing_controller (spam detection)
- [ ] Stimulus: exit_intent_controller
- [ ] Stimulus: floating_cta_controller
- [ ] Stimulus: lead_filter_controller
- [ ] Stimulus: gallery_lightbox_controller
- [ ] Stimulus: mobile_menu_controller
- [ ] NotificationMailer templates
- [ ] SmsNotificationJob
- [ ] SlackNotificationJob
- [ ] Seeds (admin user, sample leads, testimonials)
- [ ] Responsive design pass
- [ ] Tailwind theme (navy, amber, warm whites)

## Future / Backlog
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
