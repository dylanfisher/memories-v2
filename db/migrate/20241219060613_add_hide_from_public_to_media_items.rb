class AddHideFromPublicToMediaItems < ActiveRecord::Migration[6.1]
  def change
    add_column :media_items, :hide_from_public, :boolean, default: false, null: false
    add_index :media_items, :hide_from_public
  end
end
