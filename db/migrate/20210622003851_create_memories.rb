class CreateMemories < ActiveRecord::Migration[6.1]
  def change
    create_table :memories do |t|
      t.string :title
      t.date :date
      t.text :description
      t.string :media_item_range
      t.string :media_item_skip_range
      t.string :slug
      t.integer :status, default: 1, null: false
      t.jsonb :blockable_metadata, default: {}

      t.timestamps
    end
    add_index :memories, :slug, unique: true
    add_index :memories, :status
    add_index :memories, :blockable_metadata, using: :gin
  end
end
