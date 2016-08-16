namespace '/api/v1' do

  get '/' do
    'v1.0'
  end

  get '/bookings' do
    return Booking.today.to_json
  end

  get '/spaces' do
    Space.all.to_json only: [:id, :name, :code]
  end

end