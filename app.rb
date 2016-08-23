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
  if !params[:data].blank?
    begin
      data = JSON.parse(decrypt(params[:data]))
      session["uid"] = data["uid"]
    rescue Exception => e
    end
    redirect "/calendar"
  end

  @spaces = Space.all
  slim :calendar
end
