class Space < ActiveRecord::Base
  has_many :bookings, dependent: :destroy
  default_scope { order(name: :asc) }

  before_validation(on: :create) do
    # Auto capitalize :code
    self.code.upcase!
  end

end