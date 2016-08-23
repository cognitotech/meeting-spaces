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

get '/admin' do
  @current_user = User.find_by_id(session[:uid]||0)
  halt 401 if !@current_user || @current_user.role != User::ADMIN

  @users = User.all
  @spaces = Space.all
  @bookings = Booking.all
  slim :dashboard
end

get '/calendar' do
  # Deprecated path, will remove this later
  if !params[:data].blank?
    begin
      data = JSON.parse(decrypt(params[:data]))
      session[:uid] = data["uid"]
    rescue Exception => e
    end
  end
  redirect "/"
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
  @spaces = Space.all
  slim :calendar
end
