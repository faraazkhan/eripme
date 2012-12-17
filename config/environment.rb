# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Eripme::Application.initialize!

require 'tlsmail'
Eripme::Application.configure do
  Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
  config.action_mailer.delivery_method = :smtp
  #config.action_mailer.smtp_settings = $installation[:credentials][:smtp]
  if ['staging', 'production'].include? Rails.env
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.sendmail_settings = {:arguments => "-i"}
  end
end
