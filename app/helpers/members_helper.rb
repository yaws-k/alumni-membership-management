module MembersHelper
  def communication(status)
    case status
    when 'メール'
      'badge-success'
    when '郵便'
      'badge-warning'
    when '退会'
      'badge-error-content'
    end
  end

  def event_presence(presence)
    case presence
    when true
      '<div class="badge badge-primary">出席</div>'.html_safe
    when false
      '<div class="badge badge-accent">欠席</div>'.html_safe
    when nil
      '<div class="badge">未回答</div>'.html_safe
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

  def full_name_tooltip(member)
    name, phonetic = full_name(member)
    "<div class='tooltip' data-tip='#{phonetic}'>#{name}</div>".html_safe
  end

  def payment(status)
    case status
    when '未済'
      'badge badge-warning'
    when '-'
      ''
    else
      'text-success-content'
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
