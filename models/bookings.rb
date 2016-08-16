class Booking < ActiveRecord::Base
  belongs_to :space
  belongs_to :user

  scope :today, -> { where(start_time: (Time.now.beginning_of_day..Time.now.midnight)) }
end