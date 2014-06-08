class RenameTablePublisherToLabel2 < ActiveRecord::Migration
  def change
    rename_table :publishers, :labels
  end
end
