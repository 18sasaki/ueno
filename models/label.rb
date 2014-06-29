
class Label < ActiveRecord::Base
  extend RaiseCatch

  def self.get_all
    Label.all.order('name_kana')
  end

  def self.search(params)
    if params.present?
      Label.where(make_search_query(params)).order('name_kana')
    else
      Label.get_all
    end
  end

  def self.find_by_name(name, type = :eq)
    case type
    when :eq   then Label.where(name: name).first
    when :like then Label.where('name like ?', '%name%')
    end
  end

  def self.make_search_query(params)
    query_sql = []
    query_params = []

    if params['name'].present?
      query_sql << '(name like ? or name_kana like ?)'
      query_params << "%#{params['name']}%" << "%#{params['name']}%"
    end

    query_params.unshift(query_sql.join(' and '))
  end

  def insert_data(params)
    self.name      = params[:name]
    self.name_kana = params[:name_kana]
    self.save

    self #return
  end
end
