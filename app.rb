require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'active_record'

enable :sessions

get '/' do
  'Aloha!'
end

class YourApplication < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end