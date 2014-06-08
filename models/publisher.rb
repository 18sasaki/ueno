
class Label < ActiveRecord::Base
  extend RaiseCatch

  def self.get_all
    Label.all.order('name_kana')
  end

  def self.find_by_name(name, type = :eq)
    case type
    when :eq   then Label.where(name: name).first
    when :like then Label.where('name like ?', '%name%')
    end
  end

  def insert_data(params)
    self.name      = params[:name]
    self.name_kana = params[:name_kana]
    self.save

    self #return
  end
end
