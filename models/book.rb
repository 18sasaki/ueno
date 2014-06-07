
class Book < ActiveRecord::Base

  belongs_to :author
  belongs_to :publisher

  extend RaiseCatch

  def self.search(params)
    if params.present?
      Book.where(make_search_query(params)).order('name_kana')
    else
      Book.get_all
    end
  end

  def self.get_all
    Book.all.order('name_kana')
  end

  def self.make_search_query(params)
    query_sql = []
    query_params = []

    if params['publisher_id'].present?
      query_sql << 'publisher_id = ?'
      query_params << params['publisher_id']
    end

    if params['author_id'].present?
      query_sql << 'author_id = ?'
      query_params << params['author_id']
    end

    if params['name'].present?
      query_sql << '(name like ? or name_kana like ?)'
      query_params << "%#{params['name']}%" << "%#{params['name']}%"
    end

    if params['status'].present?
      query_sql << 'status = ?'
      query_params << params['status']
    end

    query_params.unshift(query_sql.join(' and '))
  end

  def insert_data(params)
    self.name = params[:name]
    self.name_kana = params[:name_kana]
    self.publisher_id = params[:publisher_id]
    self.author_id = params[:author_id]
    self.status = params[:status]
    self.save
  end
end
