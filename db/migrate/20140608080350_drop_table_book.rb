class DropTableBook < ActiveRecord::Migration
  def change
    drop_table :book
  end
end
