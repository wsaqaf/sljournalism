# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2

ActionMailer::Base.smtp_settings = {
:address => ENV["SMTP_HOST"],
:port => ENV["SMTP_PORT"],
:user_name => ENV["SMTP_USER"],
:password => ENV["SMTP_PW"],
:authentication => :login,
:enable_starttls_auto => true,
:openssl_verify_mode => 'none'
}
