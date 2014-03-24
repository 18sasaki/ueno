require 'rubygems'
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'sqlite3://localhost/myapp.db')

get '/' do
  'Heroku/Sinatra/Hello world!'
end

