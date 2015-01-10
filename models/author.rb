
class Author < ActiveRecord::Base
  default_scope { order('name_kana COLLATE "C"') } if ENV["RACK_ENV"] == "production"

  has_many :books

  extend RaiseCatch

  Required = ['name', 'name_kana']

  def self.get_all
    Author.all.order('name_kana')
  end

  def self.search(params)
    if params.present?
      Author.where(make_search_query(params)).order('name_kana')
    else
      Author.get_all
    end
  end

  def self.get_initial_list
    Author.unscoped.group('initial').pluck('initial')
  end

  def self.find_by_name(name, type = :eq)
    case type
    when :eq   then Author.where(name: name).first
    when :like then Author.where('name like ?', '%name%')
    end
  end

  def self.make_search_query(params)
    query_sql = []
    query_params = []

    if params['initial'].present?
      query_sql << 'initial = ?'
      query_params << params['initial']
    end

    if params['name'].present?
      query_sql << '(name like ? or name_kana like ?)'
      query_params << "%#{params['name']}%" << "%#{params['name']}%"
    end

    if params['sex'].present? && params['sex'] != '0'
      query_sql << 'sex = ?'
      query_params << params['sex']
    end

    query_params.unshift(query_sql.join(' and '))
  end

  def insert_data(params)
    self.name = params[:name].gsub(/\s/, '')
    self.name_kana = params[:name_kana].gsub(/\s/, '')
    self.initial = params[:name_kana].first
    self.sex = params[:sex] || '0'
    self.save

    self #return
  end
end
