class Space < ActiveRecord::Base
  has_many :bookings, dependent: :destroy
  default_scope { order(name: :asc) }

end