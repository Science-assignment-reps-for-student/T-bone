class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|

      t.string :board_title, null: false
      t.string :board_content, null: false
      t.datetime :created_at, null: false
      t.string :board_type, null: false
    end
  end
end
