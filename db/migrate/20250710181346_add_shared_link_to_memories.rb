class AddSharedLinkToMemories < ActiveRecord::Migration[6.1]
  def change
    add_column :memories, :shared_link, :string
  end
end
