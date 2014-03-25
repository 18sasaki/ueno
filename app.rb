#coding: utf-8

require 'rubygems'
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'sqlite3://localhost/myapp.db')

require_relative 'models/init'

get '/' do
  redirect '/' if params[:s] == ''

  @authors = Author.get_all(params[:s])
  erb :index
end

get '/show' do
  @author = Author.find(params[:id]) rescue Author.new
  erb :show
end

post '/create' do
  author = Author.new
  author.name = params[:name]
  author.name_kana = params[:name_kana]
  author.initial = params[:name_kana].first
  author.sex = params[:sex]
  author.save

  redirect "/?s=#{params[:s]}"
end

get '/edit' do
  @target_author = Author.find(params[:id])
  @authors = Author.get_all(params[:s])

  erb :index
end

post '/update' do
  if params[:update]
    author = Author.find(params[:id])
    author.name = params[:name]
    author.name_kana = params[:name_kana]
    author.initial = params[:name_kana].first
    author.sex = params[:sex]
    author.save
  end

  redirect "/?s=#{params[:s]}"
end

delete '/del' do
  author = Author.find(params[:id])
  author.destroy

  redirect "/?s=#{params[:s]}"
end


helpers do
  def sex_hash
    { '0' => '未設定', '1' => '男', '2' => '女', '3' => '非公開' }
  end

  def sex_translate(sex_id)
    sex_hash[sex_id.to_s]
  end
end
