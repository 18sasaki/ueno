
class Book < ActiveRecord::Base
  default_scope { order('name COLLATE "C"') } if ENV["RACK_ENV"] == "production"

  belongs_to :author
  belongs_to :label

  extend RaiseCatch

  Required = ['name', 'isbn', 'label_id', 'author_id', 'status']

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
      query_sql << 'status in (?)'
      query_params << params['status']
    end

    query_params.unshift(query_sql.join(' and '))
  end

  def self.change_status(target_id, new_status)
    target = Book.find(target_id)
    target.status = new_status
    target.save
    { status: new_status }
  rescue => e
    { error: e }
  end

  def insert_data(params)
    self.name      = params[:name]
    self.isbn      = params[:isbn]
    self.label_id  = params[:label_id]
    self.author_id = params[:author_id]
    self.save
  end
end
