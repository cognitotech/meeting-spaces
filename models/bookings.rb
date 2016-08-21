class Booking < ActiveRecord::Base
  belongs_to :space
  belongs_to :user

  default_scope { where('end_time > ?', Time.now).order(start_time: :asc) }
  scope :upcoming, -> { where('end_time > ?',Time.now).order(start_time: :asc) }

  def self.overlap?(start_dt, end_dt)
    c = self.where('(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)', start_dt, start_dt, end_dt, end_dt, start_dt, end_dt).count
    return c > 0
  end

  def self.filter_by_space_name(name)
    s = Space.find_by_name(name)
    if s
      self.upcoming.where(space: s)
    else
      nil
    end
  end
end