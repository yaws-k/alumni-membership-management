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

  # Class methods
  class << self
    # Scopes
    def accessible_years(roles: {}, current_user: nil)
      if roles[:admin] || roles[:board]
        all
      elsif roles[:lead]
        where(id: current_user.member.year_id)
      else
        where(id: nil)
      end
    end
  end
end
