class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :recoverable, :validatable, :lockable, :timeoutable, :trackable,
         :registerable

  ## Database authenticatable
  field :email,              type: String, default: ''
  index({ email: 1 }, { sparse: false, unique: true })
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token,   type: String
  index({ reset_password_token: 1 }, { sparse: true, unique: true })
  field :reset_password_sent_at, type: Time

  ## Rememberable
  # field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  index({ unlock_token: 1 }, { sparse: true, unique: true })
  field :locked_at,       type: Time
  include Mongoid::Timestamps

  # Relations
  belongs_to :member

  # Validations
  validates \
    :email,
    :encrypted_password,
    :sign_in_count,
    :failed_attempts,
    presence: true

  validates \
    :unreachable,
    inclusion: { in: [true, false] }

  # Additional fields
  field :unreachable, type: Boolean, default: false
end
