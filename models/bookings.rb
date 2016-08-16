class Booking < ActiveRecord::Base
  belongs_to :space
  belongs_to :user

  scope :today, -> { where(start_time: (Time.now.beginning_of_day..Time.now.midnight)) }

  def self.overlap?(start_dt, end_dt)
    bookings = self.where('(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)', start_dt, start_dt, end_dt, end_dt, start_dt, end_dt)
    return bookings.count > 0
  end
end