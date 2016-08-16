namespace '/api/v1' do

  before do
    @user = User.where(username: params[:user_name]).first_or_create
  end

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