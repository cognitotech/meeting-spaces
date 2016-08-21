namespace '/api/slack' do

  SYNTAX_ERROR = -1
  OVERLAP_BOOKING = 2
  INVALID_DATE = 3
  INVALID_SPACE = 4
  INVALID_DURATION = 5
  INVALID_PURPOSE = 6

  before do
    @user = User.where(username: params[:user_name]).first_or_create
    @text = params[:text]
    @url  = params[:response_url]
    @cmd  = params[:command]
    @output = ""
  end

  post '/' do

    # Handle booking syntax
    if !@text.blank? && @text.split.first.downcase == "book"
      booking = process_booking
      if booking == SYNTAX_ERROR
        return "`Invalid booking syntax` --- `#{@text}`"
      elsif booking == INVALID_SPACE
        return "Invalid room, try again` --- `#{@text}`"
      elsif booking == INVALID_DATE
        return "`Invalid booking date, try again` --- `#{@text}`"
      elsif booking == INVALID_DURATION
        return "`Invalid booking time (only 15 mins → 12 hours), try again` --- `#{@text}`"
      elsif booking == INVALID_PURPOSE
        return "`Booking purpose is short, try again` --- `#{@text}`"
      elsif booking == OVERLAP_BOOKING
        return '`Room not available` (overlapped booking)'
      else
        @output = "*Successfully* made a booking for `#{booking.purpose}` under `#{@user.username}`"
      end
    end

    # Prepare payload
    token = encrypt({"uid" => @user.id}.to_json)
    payload = {
      "text"     => "Bookings as of #{Time.now.strftime('%d/%m %H:%M')}. _<http://#{request.host}/calendar?data=#{token}|View calendar>_.",
      "parse"    => "full",
      "mrkdwn"   => true,
      "attachments" => [],
    }

    # List of upcoming bookings, group by spaces
    spaces = Space.all
    spaces.each do |s|
      bookings = s.bookings
      a = {
        "title" => "",
        "pretext" => "`#{s.code}` *#{s.name}*",
        "text" => "",
        "color" => s.color,
        "mrkdwn_in": ["text", "pretext"]
      }
      if bookings.count == 0
        a["text"] += "\n_• Free_" 
      else
        bookings.each do |b|
          if b.start_time.today?
            t = "Today #{b.start_time.strftime('%H:%M')} → #{b.end_time.strftime('%H:%M')}"
          else
            t = "#{b.start_time.strftime('%a %H:%M')} → #{b.end_time.strftime('%H:%M')}"
          end
          a["text"] += "\n• #{b.purpose} _(by #{b.user.name})_ - #{t}"
        end
      end
      payload["attachments"] << a
    end

    # Include instructions at the end
    if @output.blank?
      payload["attachments"] << {
        "title" => "",
        "pretext" => "Booking instructions",
        "text" => "#{@cmd} book `#{Space.first.code}` from `4pm` to `6pm` for `Meeting's purpose`\n
#{@cmd} book `#{Space.last.code }` from `Friday 4pm` to `6pm` for `Client Visit`\n
#{@cmd} book `#{Space.last.code }` `tomorrow 4pm` for `Interview` _(this will book 1 hour slot)_",
        "color" => "#CCC",
        "mrkdwn_in": ["text", "pretext"]
      }
    end

    # Send to Slack
    Thread.new {
      post_response(payload)
    }

    return @output
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
    return INVALID_DURATION if (end_dt - start_dt) < 15*60
    return INVALID_DURATION if (end_dt - start_dt) > 12*3600

    # Parse purpose
    purpose = matches[4]
    return INVALID purpose if purpose.length < 3

    # Create a temp booking
    if !spc.bookings.overlap?(start_dt, end_dt)
      booking = Booking.create(user: @user, space: spc, start_time: start_dt, end_time: end_dt, purpose: purpose)
      booking
    else
      return OVERLAP_BOOKING
    end
  end

  def post_response(payload = {})
    Thread.new {
      res = Net::HTTP.post_form(URI(@url), 'payload' => payload.to_json)
      p res.body
    }
  end

end