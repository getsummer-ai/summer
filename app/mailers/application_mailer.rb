class ApplicationMailer < ActionMailer::Base
  helper :email
  default from: "from@example.com"
  layout "email/mailer"
end
