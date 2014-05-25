
class Author < ActiveRecord::Base
  extend RaiseCatch

  Required = ['name', 'name_kana']

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

  def self.find_by_name(name, type = :eq)
    case type
    when :eq   then Author.where(name: name).first
    when :like then Author.where('name like ?', '%name%')
    end
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
