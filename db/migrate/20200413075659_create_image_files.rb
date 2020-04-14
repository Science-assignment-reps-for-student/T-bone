class CreateImageFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :image_files do |t|

      t.references :board, index: true
      t.string :file_name, null: false
      t.string :source, null: false
    end
  end
end
