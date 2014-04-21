
class Author < ActiveRecord::Base
  extend RaiseCatch

  def self.get_all(sort_params='')
    order_str = case sort_params
                when 'i' then 'initial'
                when 's' then 'sex, name_kana'
                when 'k' then 'name_kana'
                when 'a' then 'id'
                else          'name_kana'
                end
    Author.all.order(order_str)
  end

  def insert_data(params)
    self.name = params[:name]
    self.name_kana = params[:name_kana]
    self.initial = params[:name_kana].first
    self.sex = params[:sex]
    self.save
  end
end
