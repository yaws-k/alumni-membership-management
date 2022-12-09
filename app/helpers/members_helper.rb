module MembersHelper
  def communication(status)
    case status
    when '通常'
      'text-success'
    when '郵便'
      'text-warning'
    when '退会'
      'text-error-content'
    end
  end

  def event_presence(presence)
    case presence
    when true
      '出席'
    when false
      '欠席'
    when nil
      '未回答'
    end
  end

  def full_name(member)
    if member.maiden_name.present? || member.maiden_name_phonetic.present?
      name = "#{member.family_name}（#{member.maiden_name}）#{member.first_name}"
      phonetic = "#{member.family_name_phonetic}（#{member.maiden_name_phonetic}）#{member.first_name_phonetic}"
    else
      name = "#{member.family_name} #{member.first_name}"
      phonetic = "#{member.family_name_phonetic} #{member.first_name_phonetic}"
    end

    [name, phonetic]
  end

  def payment(status)
    case status
    when '未済'
      'text-warning'
    when '-'
      ''
    else
      'text-success'
    end
  end

  def role_name(role)
    case role
    when 'lead'
      '世話役'
    when 'board'
      '幹事'
    when 'admin'
      'システム管理者'
    else
      'エラー'
    end
  end

  def sign_in_info(user)
    return 'None' if user.sign_in_count.zero?

    "#{user.current_sign_in_at.localtime} from #{user.current_sign_in_ip}"
  end
end
