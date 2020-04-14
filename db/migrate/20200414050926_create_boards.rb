class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :class_number, null: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
