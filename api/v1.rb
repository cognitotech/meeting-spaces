namespace '/api/v1' do

  get '/' do
    'v1.0'
  end

  get '/bookings' do
    return Booking.upcoming.to_json
  end

  get '/spaces' do
    Space.all.to_json only: [:id, :name, :code]
  end

  get '/upcoming' do
    Booking.upcoming.collect do |b|
      {
        :id => b.id,
        :title => b.purpose + "\n" + b.user.username,
        :start => b.start_time,
        :end   => b.end_time,
        :space => b.space.name,
        :purpose => b.purpose,
        :username => b.user.username,
        :backgroundColor => b.space.color,
      }
    end.to_json
  end

end