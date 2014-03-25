#coding: utf-8

require 'rubygems'
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'sqlite3://localhost/myapp.db')

get '/' do
  order_str = case params[:s]
              when 'i' then 'initial'
              when 's' then 'sex, name_kana'
              when 'k' then 'name_kana'
              else          ''
              end
  @authors = Author.all.order(order_str)
  erb :index
end

get '/show' do
  @author = Author.find(params[:id]) rescue Author.new
  erb :show
end

post '/new' do
  author = Author.new
  author.name = params[:name]
  author.name_kana = params[:name_kana]
  author.initial = params[:name_kana].first
  author.sex = params[:sex]
  author.save
  redirect '/'
end

delete '/del' do
  author = Author.find(params[:id])
  author.destroy
  redirect '/'
end


class Author < ActiveRecord::Base
end


helpers do
  def sex_hash
    { '0' => '未設定', '1' => '男', '2' => '女', '3' => '非公開' }
  end

  def sex_translate(sex_id)
    sex_hash[sex_id.to_s]
  end
end
