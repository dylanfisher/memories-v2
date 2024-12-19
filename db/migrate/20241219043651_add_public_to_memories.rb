class AddPublicToMemories < ActiveRecord::Migration[6.1]
  def change
    add_column :memories, :public, :boolean, default: false, null: false
    add_index :memories, :public
  end
end
