class AddIsbnToBook < ActiveRecord::Migration
  def change
    create_table :book do |t|
      t.integer :isbn
    end
  end
end
