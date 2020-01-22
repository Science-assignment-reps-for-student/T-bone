class CreateSingleFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :single_files do |t|

      t.references :user, index: true
      t.references :homework, index: true
      t.string :source, null: false
      t.bigint :created_at, null: false
      t.boolean :late, default: false
    end
  end
end
