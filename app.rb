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
set :public_folder, 'public'
ActiveRecord::Base.default_timezone = :local

# Load APIs & Models
Dir['./lib/*.rb', './api/*.rb', './models/*.rb'].each {|file| require file }

class App < Sinatra::Base
end

get '/admin' do
  @current_user = User.find_by_id(session[:uid]||0)
  if !@current_user || @current_user.role != User::ADMIN
    halt 401
  else
    @users = User.all
    @spaces = Space.all
    @bookings = Booking.all
    slim :dashboard
  end
end

get '/' do
  # Parse & clean up parameters
  if !params[:data].blank?
    begin
      data = JSON.parse(decrypt(params[:data]))
      session[:uid] = data["uid"]
    rescue Exception => e
    end
    redirect "/"
  end

  @current_user = User.find_by_id(session[:uid]||0)
  if !@current_user
    slim :no_direct_access
  else
    @spaces = Space.all
    slim :calendar
  end
end

not_found do
  redirect "/404.html"
end

error 401 do
  redirect "/401.html"
end

error do
  redirect "/500.html"
end