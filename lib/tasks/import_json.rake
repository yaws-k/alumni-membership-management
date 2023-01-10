namespace :import_json do
  desc 'Import json files to DB'
  require 'json'

  task :do, %w[password] => :environment do |_task, args|
    logger = Logger.new($stdout)

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

    # json directory
    json_dir = Rails.root.join('tmp/export')

    # Import events
    events = {}
    File.open("#{json_dir}/events.json") do |file|
      JSON.parse(File.read(file)).each do |e|
        event = Event.create!(
          event_name: e['event_name'],
          event_date: e['event_date'],
          fee: e['fee'],
          payment_only: e['payment_only'],
          annual_fee: e['event_name'].end_with?('年会費') ? true : false,
          note: e['note']
        )
        logger.info { "#{event.event_date}: #{event.event_name}" }
        events[e['id']] = event.id
      end
    end

    # Read years json data
    Dir.glob("#{json_dir}/year*.json").each do |file|
      json = JSON.parse(File.read(file))

      # Year
      year = Year.create!(
        graduate_year: json['year'].sub('回卒', ''),
        anno_domini: json['anno_domini'][0, 4],
        japanese_calendar: json['japanese_calendar'].match(/(昭和|平成|令和)(\d+|元)/)
      )
      logger.info { year.graduate_year }

      json['members'].each do |m|
        # Member
        member = year.members.build(
          family_name_phonetic: m['family_name_phonetic'],
          maiden_name_phonetic: m['maiden_name_phonetic'],
          first_name_phonetic: m['first_name_phonetic'],
          family_name: m['family_name'],
          maiden_name: m['maiden_name'],
          first_name: m['first_name'],
          communication: m['communication'],
          quit_reason: m['withdrawal_reason'],
          occupation: m['occupation'],
          note: m['note']
        )
        m['roles'].each do |r|
          member.roles <<
            case r['role']
            when '世話役'
              'lead'
            when '幹事', '会計担当幹事', '会長', '幹事長', '会計幹事', '顧問'
              'board'
            when 'システム管理者'
              'admin'
            end
        end
        member.roles.uniq!
        member.roles.compact!
        member.save!
        logger.info { "#{member.family_name} #{member.first_name}" }

        m['users'].each do |u|
          password = SecureRandom.alphanumeric(10)
          # User
          member.users.create!(
            email: u['email'],
            password:,
            password_confirmation: password,
            sign_in_count: u['sign_in_count'],
            current_sign_in_at: u['current_sign_in_at'],
            last_sign_in_at: u['last_sign_in_at'],
            current_sign_in_ip: u['current_sign_in_ip'],
            last_sign_in_ip: u['last_sign_in_ip'],
            failed_attempts: u['failed_attempts'],
            locked_at: u['locked_at'],
            unreachable: u['unreachable']
          )
        end

        m['addresses'].each do |a|
          # Address
          member.addresses.create!(
            postal_code: a['postal_code'],
            address1: a['address1'],
            address2: a['address2'],
            unreachable: a['unreachable']
          )
        end

        m['attendances'].each do |a|
          # Attendance
          attendance = member.attendances.build(
            payment_date: a['payment_date'],
            amount: a['amount'],
            note: a['note'],
            event_id: events[a['event_id']]
          )
          attendance.application =
            case a['application']
            when '未回答'
              nil
            when '出席'
              true
            when '欠席'
              false
            end
          attendance.presence =
            case a['presence']
            when '-'
              nil
            when '出席'
              true
            when '欠席'
              false
            end
          attendance.save!
        end
      end
    end

    # Convert field data
    Member.where(communication: '通常').update_all(communication: 'メール')

    # Make test users
    if Rails.env.development?
      members = Member.where(communication: 'メール').limit(4)
      members[0].update(family_name: '管理者', family_name_phonetic: 'かんりしゃ', roles: %w[admin])
      members[0].users.first.update(email: 'admin@example.com', password: args[:password], password_confirmation: args[:password])

      members[1].update(family_name: '幹事', family_name_phonetic: 'かんじ', roles: %w[board])
      members[1].users.first.update(email: 'board@example.com', password: args[:password], password_confirmation: args[:password])

      members[2].update(family_name: '世話役', family_name_phonetic: 'せわやく', roles: %w[lead])
      members[2].users.first.update(email: 'lead@example.com', password: args[:password], password_confirmation: args[:password])

      members[3].update(family_name: '一般', family_name_phonetic: 'いっぱん', roles: [])
      members[3].users.first.update(email: 'member@example.com', password: args[:password], password_confirmation: args[:password])
    end
  end
end
