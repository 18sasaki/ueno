class CreateBook < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string  :name
      t.string  :name_kana
      t.integer :publisher_id
      t.integer :author_id
      t.integer :status
    end
  end
end
