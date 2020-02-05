class CreateNoticeFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :notice_files do |t|

      t.references :homework, index: true
      t.string :file_name, null: false
      t.string :source, null: false
    end
  end
end
