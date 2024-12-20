class AddPublicTitleToMemories < ActiveRecord::Migration[6.1]
  def change
    add_column :memories, :public_title, :string
  end
end
