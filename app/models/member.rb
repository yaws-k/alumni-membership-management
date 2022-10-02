class Member
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  belongs_to :year
  has_many :addresses, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :users, dependent: :destroy

  # Validations
  validates \
    :family_name_phonetic,
    :first_name_phonetic,
    :family_name,
    :first_name,
    :communication,
    :search_key,
    presence: true

  before_validation :generate_search_key

  # Fields
  field :family_name_phonetic, type: String
  field :maiden_name_phonetic, type: String
  field :first_name_phonetic, type: String
  field :family_name, type: String
  field :maiden_name, type: String
  field :first_name, type: String
  field :communication, type: String, default: '通常'
  field :quit_reason, type: String
  field :occupation, type: String
  field :note, type: String

  field :search_key, type: String
  index({ search_key: 1 }, { sparse: false, unique: true })

  field :roles, type: Array, default: []

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
end
