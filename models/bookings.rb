class Booking < ActiveRecord::Base
  belongs_to :space
  belongs_to :user

  scope :upcoming, -> { where(start_time: (Time.now..Time.now.end_of_week)).order(start_time: :asc) }

  def self.overlap?(start_dt, end_dt)
    c = self.where('(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)', start_dt, start_dt, end_dt, end_dt, start_dt, end_dt).count
    return c > 0
  end
end