namespace '/api/v1' do

  get '/' do
    'v1.0'
  end

  get '/bookings' do
    return Booking.all.to_json
  end

  delete '/bookings/:id' do
    begin
      u = User.find(session[:uid])
      b = Booking.find(params[:id])
      if u.role == User::ADMIN || b.user == u
        b.mark_as_cancelled
      else
        halt 401, "Unauthorized ;)"
      end
    rescue
      halt 401, "Unauthorized ;)"
    end
  end

  get '/spaces' do
    Space.all.to_json only: [:id, :name, :code]
  end

  get '/upcoming' do
    s = Chronic.parse(params[:start], guess: :begin)
    e = Chronic.parse(params[:end], guess: :end)
    if s!=nil && e!=nil
      bookings = Booking.where('start_time >= ? AND end_time <=?', s, e)
    else
      bookings = Booking.all
    end

    bookings.includes(:space, :user).collect do |b|
      {
        :id => b.id,
        :title => b.purpose + "\n" + b.user.username,
        :start => b.start_time,
        :end   => b.end_time,
        :space => b.space.name,
        :uid   => b.user.id,
        :purpose => b.purpose,
        :username => b.user.username,
        :borderColor => b.space.color,
        :backgroundColor => b.space.color,
      }
    end.to_json
  end

end