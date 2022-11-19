class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  has_many :attendances, dependent: :destroy

  # Validations
  validates \
    :event_name,
    :event_date,
    :fee,
    presence: true

  validates \
    :payment_only,
    inclusion: { in: [true, false] }

  # Fields
  field :event_name, type: String
  field :event_date, type: Date
  index({ event_date: 1 }, { sparse: false, unique: false })
  field :fee, type: Integer, default: 0
  field :payment_only, type: Boolean, default: false
  field :note, type: String

  # Class methods
  class << self
    # Scopes
    def sorted(payment_only: false)
      case payment_only
      when 'true', true
        where(payment_only: true).sort(event_date: :desc)
      when 'false', false
        where(payment_only: false).sort(event_date: :desc)
      else
        # Return no record
        []
      end
    end
  end
end
