class CreatePublisher < ActiveRecord::Migration
  def self.up
    create_table :publishers do |t|
      t.string  :name
      t.string  :name_kana
    end
  end
end
