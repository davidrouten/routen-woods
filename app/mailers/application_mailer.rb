class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "notifications@mail.routenwoods.com")
  layout "mailer"
end
