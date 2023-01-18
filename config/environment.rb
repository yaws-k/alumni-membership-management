# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  address: Rails.application.credentials.host[:mail][:server],
  port: 587,
  user_name: Rails.application.credentials.host[:mail][:user],
  password: Rails.application.credentials.host[:mail][:password]
}
