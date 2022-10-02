class Address
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  belongs_to :member

  # Filters
  before_validation :normalize

  # Validations
  validates \
    :postal_code,
    :address1,
    presence: true

  validates \
    :unreachable,
    inclusion: { in: [true, false] }

  validate :postal_code_valid?

  # Fields
  field :postal_code, type: String
  field :address1, type: String
  field :address2, type: String
  field :unreachable, type: Boolean, default: false

  private

  # Custom filters
  def normalize
    postal_code.unicode_normalize!(:nfkc).tr!('ー', '-') if postal_code.present?
    address1.unicode_normalize!(:nfkc) if address1.present?
    address2.unicode_normalize!(:nfkc) if address2.present?
  end

  # Custom validations
  def postal_code_valid?
    case postal_code
    when /^\d{3}-\d{4}$/
      return true
    when /^\d{7}$/
      self.postal_code = "#{postal_code[0, 3]}-#{postal_code[3, 4]}"
      return true
    end

    errors.add(:postal_code, '郵便番号の形式が誤っています。なお、住所は日本国内の形式にしか対応していません。')
  end
end
