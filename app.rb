#coding: utf-8

require 'nokogiri'
require 'rubygems'
require 'sinatra'
require 'active_record'
require 'amazon/ecs'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'sqlite3://localhost/myapp.db')

require_relative 'models/init'

Amazon::Ecs.configure do |options|
  options[:associate_tag] = ENV['ASSOCIATE_TAG']
  options[:AWS_access_key_id] = ENV['AWS_ACCESS_KEY_ID']
  options[:AWS_secret_key] = ENV['AWS_SECRET_KEY']
  options[:country] = 'jp'
end

enable :sessions
set :session_secret, '18sasaki'

# top
get '/' do
  erb :index
end


# author
get '/author' do
  redirect '/author/'
end

get '/author/' do
  @authors = Author.search(session[:author])
  erb :author_index
end

# 検索用
post '/author/' do
  session[:author] = params[:search_button] ? params_to_session(params) : {}
  @authors = Author.search(session[:author])
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
  redirect "/author/"
end

get '/author/edit' do
  @target_author = Author.find(params[:id])
  @authors = Author.search(session[:author])
  erb :author_index
end

post '/author/update' do
  Author.find(params[:id]).insert_data(params) if params[:update]
  redirect "/author/"
end

delete '/author/del' do
  Author.find(params[:id]).destroy
  redirect "/author/"
end


# label
get '/label' do
  redirect '/label/'
end

get '/label/' do
  @labels = Label.get_all
  erb :label_index
end

# 検索用
post '/label/' do
  session[:label] = params[:search_button] ? params_to_session(params) : {}
  @labels = Label.search(session[:label])
  erb :label_index
end

post '/label/create' do
  Label.new.insert_data(params)
  redirect '/label/'
end

get '/label/edit' do
  @target_label = Label.find(params[:id])
  @labels = Label.get_all
  erb :label_index
end

post '/label/update' do
  Label.find(params[:id]).insert_data(params) if params[:update]
  redirect '/label/'
end

delete '/label/del' do
  Label.find(params[:id]).destroy
  redirect '/label/'
end


# book
get '/book' do
  redirect '/book/'
end

get '/book/' do
  @books = Book.search(session[:book])
  @authors = Author.get_all
  @labels = Label.get_all
  erb :book_index
end

# 検索用
post '/book/' do
  session[:book] = params[:search_button] ? params_to_session(params) : {}
  @books = Book.search(session[:book])
  @authors = Author.get_all
  @labels = Label.get_all
  erb :book_index
end

post '/book/create' do
  Book.new.insert_data(params)
  redirect '/book/'
end

get '/book/edit' do
  @target_book = Book.find(params[:id])
  @books = Book.search(session[:book])
  @authors = Author.get_all
  @labels = Label.get_all
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


# search
get '/search' do
  redirect '/search/'
end

get '/search/' do
  erb :search_index
end

post '/search/' do
  if params[:isbn]
    formatted_isbn = if params[:isbn_13].present?
                       '978' + params[:isbn_13].gsub(/[^0-9X]/, '')
                     else
                       params[:isbn_10].gsub(/[^0-9X]/, '')
                     end
    search_result = Search.search_by_isbn(formatted_isbn)
  elsif params[:title]
    search_result = Search.search_by_title(params[:title_str])
  end
  @data_list = search_result[:data_list]
  @error     = search_result[:error]

  erb :search_index
end

get '/search/book_register' do
  @author_id = params[:author_id].presence || Search.get_author_id(params[:author_name])
  @authors = Author.get_all
  @label_id = params[:label_id].presence || Search.get_label_id(params[:label_name])
  @labels = Label.get_all
  erb :search_book_register
end

post '/search/author_register' do
  new_author = Author.new.insert_data(params)
  new_params = params['original'].merge({author_id: new_author.id, author_name: new_author.name})
  redirect "/search/book_register?#{data_to_query(new_params)}"
end

post '/search/label_register' do
  new_label = Label.new.insert_data(params)
  new_params = params['original'].merge({label_id: new_label.id, label_name: new_label.name})
  redirect "/search/book_register?#{data_to_query(new_params)}"
end

post '/search/book_register' do
  Book.new.insert_data(params)
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

get '/api/get_all_labels' do
  json ({}.tap { |ret_hash| Label.get_all.each { |label| ret_hash[label.id] = label.attributes } })
end

get '/api/get_label' do
  return_attributes(Label.find(params[:id]))
end

get '/api/get_all_books' do
  json ({}.tap { |ret_hash| Book.get_all.each { |book| ret_hash[book.id] = book.attributes } })
end

get '/api/get_book' do
  return_attributes(Book.find(params[:id]))
end

get '/api/change_book_status' do
  result = Book.change_status(params[:id], params[:new_status])
  json ({error: result[:error], status: status_translate(result[:status]), next_status_id: get_next_status_id(result[:status].to_i)})
end

post '/api/register_book' do
  # 必須パラメータ確認
  check_params(params, 'book')

  new_book = Book.new.insert_data(params)
  return_attributes(new_book)
end



helpers do
  def sex_hash
    { '0' => '', '1' => '男', '2' => '女', '3' => '非公開' }
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

  def get_next_status_id(current_status_id)
    case current_status_id
    when 0 then 1
    when 1 then 2
    when 2 then 3
    when 3 then 0
    end
  end

  def get_status_and_next_id(status_int)
    next_status_id = get_next_status_id(status_int)
    return [status_translate(status_int), next_status_id]
  end

  def initial_list
    # TODO: 初期ロードで作っておく（Authorの変更時に修正するメソッド呼ぶ）
    Author.group('initial').pluck('initial')
  end

  def data_to_query(data)
    URI.encode(data.map do |k, v|
                 "#{k}=#{v}"
               end.join('&'))
  end

  def params_to_session(params)
    {}.tap do |ses|
      params.each do |k, v|
        next if k == 'search_button'
        ses[k] = v
      end
    end
  end

  def nav_link_set
    [
      ['Top', '/'],
      ['Author', '/author/'],
      ['Label', '/label/'],
      ['Book', '/book/'],
      ['Search', '/search/']
    ]
  end
end
