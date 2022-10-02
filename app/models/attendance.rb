class Attendance
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  belongs_to :member
  belongs_to :event

  # Validations
  validates \
    :amount,
    presence: true

  validates \
    :application,
    :presence,
    inclusion: { in: [nil, true, false] }

  # Fields
  field :application, type: Boolean, default: nil
  field :presence, type: Boolean, default: nil

  field :payment_date, type: Date
  field :amount, type: Integer, default: 0
  field :note, type: String
end
