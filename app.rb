require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require 'sinatra/json'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'active_record'
require 'awesome_print'
require 'chronic'

 Time.zone = "Singapore"
 ActiveRecord::Base.default_timezone = :local

# Load APIs & Models
Dir['./api/*.rb', './models/*.rb'].each {|file| require file }

class App < Sinatra::Base
end

get '/' do
  'Hi!'
end
