namespace '/api' do

  SYNTAX_ERROR = -1
  OVERLAP_BOOKING = 2
  INVALID_DATE = 3
  INVALID_SPACE = 4

  before do
    @user = User.where(username: params[:user_name]).first_or_create
    @text = params[:text]
    @output = ["*======== Upcoming bookings ========*"]
  end

  post '/slack' do

    # Handle booking syntax
    if !@text.blank? && @text.split.first.downcase == "book"
      booking = process_booking
      ap booking
      if booking == SYNTAX_ERROR
        return "`Invalid booking syntax` --- `#{@text}`"
      elsif booking == INVALID_DATE
        return "Invalid room, try again` --- `#{@text}`"
      elsif booking == INVALID_DATE
        return "`Invalid booking date, try again` --- `#{@text}`"
      elsif booking == OVERLAP_BOOKING
        return '`Room not available` (overapped booking)'
      else
        @output << ["Successfully made a booking for `#{booking.purpose}` under `#{@user.username}`"]
      end
    end

    # List of upcoming bookings
    spaces = Space.all
    spaces.each do |s|
      bookings = s.bookings.upcoming
      @output << "`#{s.code}` *#{s.name}*"
      @output << "_ • Free_" if bookings.count == 0
      bookings.upcoming.each do |b|
        if b.start_time.today?
          t = "Today #{b.start_time.strftime('%H:%M')} → #{b.end_time.strftime('%H:%M')}"
        else
          t = "#{b.start_time.strftime('%a %H:%M')} → #{b.end_time.strftime('%H:%M')}"
        end
        @output << " • #{b.purpose} (by #{b.user.name}) - #{t}"
      end
    end

    # Instruction
    @output << "================================"
    @output << "View Calendar https://rooms.ssf.vn/calendar"
    @output << "================================"
    @output << "/rooms book `#{Space.first.code}` from `4pm` to `6pm` for `Meeting's purpose`"
    @output << "/rooms book `#{Space.last.code }` from `Friday 4pm` to `6pm` for `Client Visit`"
    @output << "/rooms book `#{Space.last.code }` `tomorrow 4pm` for `Interview`  _(1 hour slot)_"

    @output.join "\n"
  end

  def process_booking
    # Extract params
    matches = @text.scan /book (\S+) (from )?(.+) to (.+) for (.+)/
    if matches.count == 1
      matches = matches.first
    else
      matches = @text.scan /book (\S+) (from )?(.+) for (.+)/
      if matches.count == 1
        matches = matches.first
        matches[4] = matches[3]
        matches[3] = nil # to match alternate syntax
      end
    end
    return SYNTAX_ERROR if matches.count < 5

    # Find the space
    spc = Space.find_by_code(matches[0].upcase)
    return INVALID_SPACE if spc == nil

    # Parse start datetime
    start_dt = Chronic.parse(matches[2], now: Time.now)
    return INVALID_DATE if start_dt == nil || start_dt < Time.now

    # Parse end datetime (or assume 1 hour)
    end_dt = start_dt + 3600
    if matches[3] != nil
      end_dt = Chronic.parse(matches[3], now: start_dt)
    end
    return INVALID_DATE if end_dt == nil || end_dt <= start_dt

    # Parse purpose
    purpose = matches[4]

    # Create a temp booking
    if !spc.bookings.overlap?(start_dt, end_dt)
      booking = Booking.create(user: @user, space: spc, start_time: start_dt, end_time: end_dt, purpose: purpose)
      booking
    else
      return OVERLAP_BOOKING
    end
  end

end