class CreateMultiFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :multi_files do |t|

      t.references :team, index: true
      t.references :homework, index: true
      t.string :file_name, null: false
      t.string :source, null: false
      t.datetime :created_at, null: false
      t.boolean :late, null: false
    end
  end
end
