class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :user, index: true
      t.references :board, index: true
      t.text :description, null: false

      t.timestamps
    end
  end
end
