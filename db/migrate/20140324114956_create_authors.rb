class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string  :name
      t.string  :name_kana
      t.string  :initial
      t.integer :sex
    end
  end
end
