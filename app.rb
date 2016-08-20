require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require 'sinatra/json'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'active_record'
require 'awesome_print'
require 'chronic'
require 'net/http'
require 'json'
require 'openssl'
require 'digest/sha2'

# Global configs
enable :sessions
ActiveRecord::Base.default_timezone = :local

# Load APIs & Models
Dir['./lib/*.rb', './api/*.rb', './models/*.rb'].each {|file| require file }

class App < Sinatra::Base
end

get '/' do
  'Hi!'
end

get '/admin' do
  @users = User.all
  @spaces = Space.all
  @bookings = Booking.all
  slim :dashboard
end

get '/calendar' do
  # Parse & clean up parameters
  filter = params[:filter] || "All"
  if !params[:data].blank?
    begin
      data = JSON.parse(decrypt(params[:data]))
      session["uid"] = data["uid"]
    rescue Exception => e
    end
    redirect "/calendar?filters=#{filter}"
  end

  # Retrieve bookings and group by weekdays
  @spaces = Space.all
  @weekdays = {"Mon" => [], "Tue" => [], "Wed" => [], "Thu" => [], "Fri" => [], "Sat" => [], "Sun" => []}
  @bookings =  Space.all.pluck(:name).include?(filter) ? Booking.filter_by_space_name(filter) : Booking.upcoming
  @bookings.each do |b|
    a = b.start_time.strftime '%a'
    @weekdays[a].push(b) if @weekdays[a]
  end
  slim :calendar
end

get '/slack-setup' do
  slim :slack_setup
end


