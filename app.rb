require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require 'sinatra/json'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'active_record'
require 'awesome_print'
require 'chronic'

Time.zone = "Hanoi"
ActiveRecord::Base.default_timezone = :local

# Load APIs & Models
Dir['./api/*.rb', './models/*.rb'].each {|file| require file }

class App < Sinatra::Base
end

get '/' do
  'Hi!'
end

namespace '/admin' do
  get '/' do
    @users = User.all
    @spaces = Space.all
    @bookings = Booking.all
    slim :dashboard
  end

  get '/calendar' do
    @spaces = Space.all
    @bookings = Booking.upcoming
    @weekdays = {"Mon" => [], "Tue" => [], "Wed" => [], "Thu" => [], "Fri" => []}
    @bookings.each do |b|
      a = b.start_time.strftime '%a'
      @weekdays[a].push(b)
    end
    ap @weekdays
    slim :calendar
  end
end