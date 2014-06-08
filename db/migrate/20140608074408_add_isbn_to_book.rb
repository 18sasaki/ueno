class AddIsbnToBook < ActiveRecord::Migration
  def change
    add_column :books, :isbn, :integer
  end
end
