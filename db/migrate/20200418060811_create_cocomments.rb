class CreateCocomments < ActiveRecord::Migration[6.0]
  def change
    create_table :cocomments do |t|
      t.references :user, index: true
      t.references :comment, index: true
      t.text :description, null: false

      t.timestamps
    end
  end
end
