namespace '/api/v1' do

  get '/' do
    'v1.0'
  end

  get '/bookings' do
    return Booking.all.to_json
  end

  delete '/bookings/:id' do
    begin
      Booking.find(params[:id]).mark_as_cancelled
    rescue
    end
  end

  get '/spaces' do
    Space.all.to_json only: [:id, :name, :code]
  end

  get '/upcoming' do
    Booking.all.collect do |b|
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