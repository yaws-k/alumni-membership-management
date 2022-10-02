class Year
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  has_many :members

  # Validations
  validates \
    :graduate_year,
    :anno_domini,
    :japanese_calendar,
    presence: true

  # Fields
  field :graduate_year, type: String
  field :anno_domini, type: Integer
  field :japanese_calendar, type: String
end
