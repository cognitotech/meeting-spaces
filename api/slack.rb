namespace '/api' do

  before do
    ap params
    @user = User.where(username: params[:user_name]).first_or_create
    @text = params[:text]
    @output = []

    # /rooms book DV 3pm to 4pm
  end

  post '/slack' do

    # List of upcoming bookings
    spaces = Space.all
    spaces.each do |s|
      @output << "`#{s.code}` *#{s.name}*"
      @output << "_ • Free_" if s.bookings.count == 0
      s.bookings.each do |b|
        @output << " • #{b.purpose} (by #{b.user.name}) - #{b.start_time.strftime('%H:%M')} → #{b.end_time.strftime('%H:%M')}"
      end
    end

    # Instruction
    @output << "================================"
    @output << "/rooms book `#{Space.first.code}` from `4pm` for `2.5h`"

    @output.join "\n"
  end

end