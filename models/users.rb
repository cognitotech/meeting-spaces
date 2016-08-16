class User < ActiveRecord::Base
  has_many :bookings, dependent: :destroy

  before_validation(on: :create) do
    # Auto fill name with username
    self.name = self.username
  end

end