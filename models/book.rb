
class Book < ActiveRecord::Base

  belongs_to :author
  belongs_to :publisher

  extend RaiseCatch

  def self.get_all
    Book.all.order('name_kana')
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
