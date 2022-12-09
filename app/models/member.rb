class Member
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  belongs_to :year
  has_many :addresses, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :users, dependent: :destroy

  # Before validation
  before_validation  \
    :generate_search_key

  # Validations
  validates \
    :family_name_phonetic,
    :first_name_phonetic,
    :family_name,
    :first_name,
    :communication,
    :search_key,
    presence: true

  validate \
    :phonetic_valid?,
    :name_valid?

  before_save \
    :normalize_phonetics,
    :normalize_names

  # Fields
  field :family_name_phonetic, type: String
  field :maiden_name_phonetic, type: String
  field :first_name_phonetic, type: String
  field :family_name, type: String
  field :maiden_name, type: String
  field :first_name, type: String
  field :communication, type: String, default: 'メール'
  field :quit_reason, type: String
  field :occupation, type: String
  field :note, type: String

  field :search_key, type: String
  index({ search_key: 1 }, { sparse: false, unique: true })

  field :roles, type: Array, default: []

  # Class methods
  class << self
    def payment_status
      annual_fee = nil
      Event.sorted(payment_only: true).each do |rec|
        if rec.event_name.end_with?('年会費')
          annual_fee = rec
          break
        end
      end
      payments = Attendance.where(event_id: annual_fee.id).pluck(:member_id, :payment_date).to_h
      status = {}
      Member.all.only(:id, :communication).each do |m|
        status[m.id] =
          if m.communication == '退会' || m.communication == '逝去'
            '-'
          elsif payments[m.id].present?
            payments[m.id]
          else
            '未済'
          end
      end
      status
    end

    def year_sort(id: [], order: :desc)
      # Group members by year_id
      member_h = {}
      self.in(id:).order(search_key: :asc).each do |rec|
        member_h[rec.year_id] ||= []
        member_h[rec.year_id] << rec
      end

      # Pick members
      members = []
      Year.in(id: member_h.keys).order(anno_domini: order).pluck(:id).each do |year_id|
        members.concat(member_h[year_id])
      end
      members
    end
  end

  private

  # Callback
  def generate_search_key
    self.search_key =
      family_name_phonetic +
      maiden_name_phonetic.to_s +
      first_name_phonetic +
      family_name +
      maiden_name.to_s +
      first_name
  end

  # Custom validation
  def phonetic_valid?
    errors.add(:family_name_phonetic, '名字の読み仮名に漢字や記号が入っています。') if phonetic_check(str: family_name_phonetic)
    errors.add(:first_name_phonetic,  '名前の読み仮名に漢字や記号が入っています。') if phonetic_check(str: first_name_phonetic)
    errors.add(:maiden_name_phonetic, '旧姓の読み仮名に漢字や記号が入っています。') if phonetic_check(str: maiden_name_phonetic)
  end

  def name_valid?
    errors.add(:family_name, '名字に記号など不正な文字が入っています。') if name_check(str: family_name)
    errors.add(:first_name,  '名前に記号など不正な文字が入っています。') if name_check(str: first_name)
    errors.add(:maiden_name, '旧姓に記号など不正な文字が入っています。') if name_check(str: maiden_name)
  end

  def phonetic_check(str: nil)
    return false if str.blank?
    return true if str.match(/\p{Han}/)

    name_check(str:)
  end

  def name_check(str: nil)
    return false if str.blank?
    return true if str.strip.unicode_normalize(:nfkc).match(/[ 　‐‑–—―−ｰ,.\/（）\(\)]/)

    false
  end

  def normalize_phonetics
    self.family_name_phonetic = phonetic_conv(str: family_name_phonetic)
    self.first_name_phonetic = phonetic_conv(str: first_name_phonetic)
    self.maiden_name_phonetic = phonetic_conv(str: maiden_name_phonetic)
  end

  def phonetic_conv(str: nil)
    return '' if str.blank?

    normalized = str.strip.unicode_normalize(:nfkc)
    if normalized.include?('?')
      '？？？？？'
    else
      normalized.tr('ァ-ン', 'ぁ-ん')
    end
  end

  def normalize_names
    self.family_name = name_conv(str: family_name)
    self.first_name = name_conv(str: first_name)
    self.maiden_name = name_conv(str: maiden_name)
  end

  def name_conv(str: nil)
    return '' if str.blank?

    normalized = str.strip.unicode_normalize(:nfkc)
    if normalized.include?('?')
      '？？？？？'
    else
      normalized
    end
  end
end
