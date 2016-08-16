namespace '/api' do

  before do
    @user = User.where(username: params[:user_name]).first_or_create
    @text = params[:text]
    @output = []

    # /rooms book DV from 3pm for 1h
    if !@text.blank? && @text.split.first.downcase == "book"
      booking = process_booking
      return "Invalid booking syntax" if !booking
      booking.save
    end
  end

  post '/slack' do
    Time.zone = "Asia/Hong_Kong"

    # List of upcoming bookings
    spaces = Space.all
    spaces.each do |s|
      @output << "`#{s.code}` *#{s.name}*"
      @output << "_ • Free_" if s.bookings.count == 0
      s.bookings.each do |b|
        ap b.start_time
        @output << " • #{b.purpose} (by #{b.user.name}) - #{b.start_time.strftime('%H:%M')} → #{b.end_time.strftime('%H:%M')}"
      end
    end

    # Instruction
    @output << "================================"
    @output << "/rooms book `#{Space.first.code}` from `4pm` for `2.5h`"
    @output << "/rooms _mine_"

    @output.join "\n"
  end

  def process_booking
    # Extract params
    matches = @text.scan /book (\S+) from (.+) for (.+)/
    return nil if matches.count < 1 || matches.first.count < 3
    matches = matches.first

    # Find the space
    spc = Space.find_by_code(matches[0])
    return nil if spc == nil

    # Parse start datetime
    start_dt = Chronic.parse(matches[1])
    return nil if start_dt == nil

    # Parse duration to get end datetime
    dur = ChronicDuration.parse(matches[2])
    return nil if dur == nil
    end_dt = start_dt + dur

    # Create a temp booking
    if !spc.bookings.overlap?(start_dt, end_dt)
      booking = Booking.new(user: @user, space: spc, start_time: start_dt, end_time: end_dt)
    else
      p "Overlapped booking"
      return nil
    end
  end

end