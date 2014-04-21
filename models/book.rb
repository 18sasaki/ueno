
class Book < ActiveRecord::Base

  belongs_to :author
  belongs_to :publisher

  extend RaiseCatch

  def self.get_all(sort_params='')
    order_str = case sort_params
                when 'i' then 'initial'
                when 's' then 'sex, name_kana'
                when 'k' then 'name_kana'
                else          'name_kana'
                end
    Book.all.order(order_str)
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
