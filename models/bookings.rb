class Booking < ActiveRecord::Base
  belongs_to :space
  belongs_to :user

  validate :start_time_cannot_be_in_the_past
  validate :end_time_cannot_be_earlier_than_start_time
  validate :end_time_is_too_short_or_too_long
  validate :end_time_is_not_crossing_next_day

  # state
  ACTIVE = 0
  CANCELLED = 1

  default_scope { where('end_time > ?', Time.now).where(state: ACTIVE).order(start_time: :asc) }

  def self.overlap?(start_dt, end_dt)
    c = self.where('(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)', start_dt, start_dt, end_dt, end_dt, start_dt, end_dt).count
    return c > 0
  end

  def self.filter_by_space_name(name)
    s = Space.find_by_name(name)
    if s
      self.where(space: s)
    else
      nil
    end
  end

  def mark_as_cancelled
    update_attribute :state, CANCELLED
  end

  def start_time_cannot_be_in_the_past
    if start_time < Time.now
      errors.add(:start_time, "can't be in the past")
    end
  end

  def end_time_cannot_be_earlier_than_start_time
    if end_time <= start_time
      errors.add(:end_time, "can't be earlier than start time")
    end
  end

  def end_time_is_too_short_or_too_long
    d = end_time - start_time
    if d < 15*60 || d > 12*3600
      errors.add(:end_time, "duration must be within 15 mins to 12 hours")
    end
  end

  def end_time_is_not_crossing_next_day
    if end_time.day != start_time.day
      errors.add(:end_time, "must not crossing to next day")
    end
  end

end