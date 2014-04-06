
class Publisher < ActiveRecord::Base
  def self.get_all
    Publisher.all.order('name_kana')
  end

  def insert_data(params)
    self.name = params[:name]
    self.name_kana = params[:name_kana]
    self.save
  end
end
