#coding: utf-8

require 'rubygems'
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'sqlite3://localhost/myapp.db')

require_relative 'models/raise_catch'
require_relative 'models/init'


# top
get '/' do
  erb :index
end


# author
get '/author' do
  redirect '/author/'
end

get '/author/' do
  redirect '/author/' if params[:s] == ''
  @authors = Author.get_all(params[:s])
  erb :author_index
end

# get '/*' do
#   klass = params[:splat].first
#   redirect "/#{klass}" if params[:s] == ''
#   @authors = eval(klass.classify).get_all(params[:s])
#   erb "#{klass}/index"
# end

get '/author/show' do
  @author = Author.find(params[:id])
  erb :author_show
end

post '/author/create' do
  Author.new.insert_data(params)
  redirect "/author?s=#{params[:s]}"
end

get '/author/edit' do
  @target_author = Author.find(params[:id])
  @authors = Author.get_all(params[:s])
  erb :author_index
end

post '/author/update' do
  Author.find(params[:id]).insert_data(params) if params[:update]
  redirect "/author?s=#{params[:s]}"
end

delete '/author/del' do
  Author.find(params[:id]).destroy
  redirect "/author?s=#{params[:s]}"
end


# publisher
get '/publisher' do
  redirect '/publisher/'
end

get '/publisher/' do
  @publishers = Publisher.get_all
  erb :publisher_index
end

post '/publisher/create' do
  Publisher.new.insert_data(params)
  redirect '/publisher/'
end

get '/publisher/edit' do
  @target_publisher = Publisher.find(params[:id])
  @publishers = Publisher.get_all
  erb :publisher_index
end

post '/publisher/update' do
  Publisher.find(params[:id]).insert_data(params) if params[:update]
  redirect '/publisher/'
end

delete '/publisher/del' do
  Publisher.find(params[:id]).destroy
  redirect '/publisher/'
end


# book
get '/book' do
  redirect '/book/'
end

get '/book/' do
  @books = Book.get_all
  @authors = Author.get_all
  @publishers = Publisher.get_all
  erb :book_index
end

post '/book/create' do
  Book.new.insert_data(params)
  redirect '/book/'
end

get '/book/edit' do
  @target_book = Book.find(params[:id])
  @books = Book.get_all
  @authors = Author.get_all
  @publishers = Publisher.get_all
  erb :book_index
end

post '/book/update' do
  Book.find(params[:id]).insert_data(params) if params[:update]
  redirect '/book/'
end

delete '/book/del' do
  Book.find(params[:id]).destroy
  redirect '/book/'
end



# API
def return_attributes(instance)
  json instance ? instance.attributes : Hash.new
end

def check_params(params, type)
  lack_params = eval(type.classify)::Required.select{ |required| !params[required] }
  if lack_params.present?
    raise "parameter is lack : #{lack_params.join(',')}"
  end
end

get '/api/get_all_authors' do
  json ({}.tap { |ret_hash| Author.get_all.each { |author| ret_hash[author.id] = author.attributes } })
end

get '/api/get_author' do
  return_attributes(Author.find(params[:id]))
end

get '/api/set_author' do
  begin
    check_params(params, 'author')
    return_attributes(Author.new.insert_data(params))
  rescue => e
    json "Error !!!  #{e}"
  end
end

get '/api/get_all_publishers' do
  json ({}.tap { |ret_hash| Publisher.get_all.each { |publisher| ret_hash[publisher.id] = publisher.attributes } })
end

get '/api/get_publisher' do
  return_attributes(Publisher.find(params[:id]))
end

get '/api/get_all_books' do
  json ({}.tap { |ret_hash| Book.get_all.each { |book| ret_hash[book.id] = book.attributes } })
end

get '/api/get_book' do
  return_attributes(Book.find(params[:id]))
end



helpers do
  def sex_hash
    { '0' => '未設定', '1' => '男', '2' => '女', '3' => '非公開' }
  end

  def sex_translate(sex_int)
    sex_hash[sex_int.to_s]
  end

  def status_hash
    { '0' => '未購入', '1' => '欲しい', '2' => '購入済', '3' => '読了' }
  end

  def status_translate(status_int)
    status_hash[status_int.to_s]
  end
end
