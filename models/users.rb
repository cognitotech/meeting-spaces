class User < ActiveRecord::Base
  has_many :bookings, dependent: :destroy

  USER = 0
  ADMIN = 99

  default_scope { order(id: :asc) }

  before_validation(on: :create) do
    # Auto fill name with username
    self.name = self.username
  end

  def isAdmin?
    return role == ADMIN
  end

end