class RenameBookColumnPublisherIdToLabelId < ActiveRecord::Migration
  def self.up
    rename_column :books, :publisher_id, :label_id
  end
  def self.down
    rename_column :books, :label_id, :publisher_id
  end
end
