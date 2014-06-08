class RemoveNameKanaToBook < ActiveRecord::Migration
  def change
    remove_column :books, :name_kana
  end
end
