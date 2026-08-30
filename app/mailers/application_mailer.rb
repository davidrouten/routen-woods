class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default from: ENV.fetch("MAILER_FROM", "notifications@mail.routenwoods.com")
  layout "mailer"
end
