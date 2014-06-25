
class Book < ActiveRecord::Base

  belongs_to :author
  belongs_to :label

  extend RaiseCatch

  def self.search(params)
    if params.present?
      Book.where(make_search_query(params)).order('name')
    else
      Book.get_all
    end
  end

  def self.get_all
    Book.all.order('name')
  end

  def self.get_by_isbn(isbn)
    Book.find_by_isbn(isbn)
  end

  def self.make_search_query(params)
    query_sql = []
    query_params = []

    if params['label_id'].present?
      query_sql << 'label_id = ?'
      query_params << params['label_id']
    end

    if params['author_id'].present?
      query_sql << 'author_id = ?'
      query_params << params['author_id']
    end

    if params['name'].present?
      query_sql << 'name like ?'
      query_params << "%#{params['name']}%"
    end

    if params['status'].present?
      query_sql << 'status = ?'
      query_params << params['status']
    end

    query_params.unshift(query_sql.join(' and '))
  end

  def insert_data(params)
    self.name      = params[:name]
    self.isbn      = params[:isbn]
    self.label_id  = params[:label_id]
    self.author_id = params[:author_id]
    self.status    = params[:status]
    self.save
  end
end
