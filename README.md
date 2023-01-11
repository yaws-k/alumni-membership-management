# Alumni Membership Management

## TL;DR

- A membership management web system dedicated to where I belong to
- It manages the member list, annual fee payment status, and event participation

I started this project to reduce my workload while working for an alumni association as a volunteer. Though this project is open-sourced, it will not suit your alumni association out of the box. There are hardcoded logics to align with the specialized rules for mine.
I will fix only critical issues and security updates for this project till the end of 2023 because I have already retired from working as a voluntary board member.

You can see user stories [on Airtable (written in Japanese)](https://airtable.com/shrNm3h6yWEVP3G0u)

The user manual is on [this repository's Wiki](https://github.com/yaws-k/alumni-membership-management/wiki)

## Requirements

- Ruby version 3.2.x
- Ruby on Rails 7.0.x

Additional explanations for the added gems in Gemfile

### MongoDB

Unlike other Ruby on Rails projects, it uses MongoDB instead of the usual RDBs. Please install MongoDB if you want to run this service on your site.

### cssbundling-rails for Tailwind CSS

RoR 7 offers Tailwind CSS easy installer, but this mechanism doesn't accept any plugins. To use daisyUI and Prose plugin, this project uses cssbundling-rails.

### Devise

For user authentication, this project uses Devise. As of December 2022, Devise doesn't like Turbo for RoR 7. To avoid issues with turbo, custom views to use "data: { turbo: false}" are generated under app/views/devise.

### haml

Instead of erb, this project uses haml. Better performance and less codes, but sometimes more complicated...

### Mongoid

Instead of ActiveRecord, this project requires Mongoid to work with MongoDB. It almost works the same as ActiveRecord, but some queries look different.
If you try using an RDB with ActiveRecord, critical logic will not work.

### rubyXL

It uses rubyXL to export data to Excel (.xlsx) file.
You might think CSV should be enough, but there are complicated Kanji and Japanese Excel file encoding issues...

### sd_notify

This gem is required to connect puma and Rails via the unix socket.

## Configuration

credentials.yml looks like as below.

```yaml
secret_key_base: abcdefghi...

mongodb:
  development:
    dbname: development_database_name
    user: development_user_name
    password: development_password
  test:
    dbname: test_database_name
    user: test_user_name
    password: test_password
  production:
    dbname: production_database_name
    user: production_user_name
    password: production_password

host:
  mail: mail.server.fqdn
  sender: admin@example.com
  production: production.fqdn.name

alumni: alumni name displayed on the main page

matomo:
  site: you-matomo.site.name
  siteid: siteID number
```

### mongodb

MongoDB database name, username, and password will be specified here.

### host

The mail server is specified in config/environment.rb
The mail sender is specified in config/config/initializers/devise.rb
The production FQDN is specified in config/environments/production.rb

### alumni

This is the alumni's name to display on the main page (members/index).

### matomo

If these parameters are specified, Matomo tracking javascript will be activated in app/views/layouts/application.html.haml

## Database initialization

It must have at least one admin to start. Run `bin/rails init_db:do` to create the first user.
This Rake task will show you the email and randomly generated initial password. Use these credentials and start from updating this users information.

## Test suite

Run `bin/rspec`. This system uses RSpec.
This repository has [GitHub Actions configuration](https://github.com/yaws-k/alumni-membership-management/blob/main/.github/workflows/rspec.yml) and [mongoid.yml for this action](https://github.com/yaws-k/alumni-membership-management/blob/main/config/mongoid.yml.ci)
