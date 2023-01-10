namespace :init_db do
  desc 'Initialize DB'

  task :do, %w[password] => :environment do |_task, args|
    # Refresh DB
    Event.collection.drop
    Attendance.collection.drop
    Address.collection.drop
    User.collection.drop
    Member.collection.drop
    Year.collection.drop

    Event.create_indexes
    Attendance.create_indexes
    Address.create_indexes
    User.create_indexes
    Member.create_indexes
    Year.create_indexes

    # Set password
    password =
      if args[:password].blank?
        Faker::Alphanumeric.alphanumeric(number: 20)
      else
        args[:password]
      end

    # Create documents
    year = Year.create!(
      graduate_year: '高999',
      anno_domini: 2999,
      japanese_calendar: '令和999'
    )

    member = year.members.create!(
      family_name: 'admin',
      family_name_phonetic: 'admin',
      first_name: 'user',
      first_name_phonetic: 'user',
      communication: 'メール',
      roles: %w[board admin]
    )

    member.users.create!(
      email: 'admin@example.com',
      password:,
      password_confirmation: password,
      unreachable: false
    )

    puts "EMail: #{User.first.email}"
    puts "Password: #{password}"

    Event.create!(
      event_name: 'dummy',
      event_date: Date.today,
      fee: 100,
      payment_only: true,
      annual_fee: true
    )
  end
end
