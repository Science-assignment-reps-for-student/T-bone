class AddConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :multi_files, :late, :boolean
    add_index :teams, [:leader_id, :homework_id], unique: true
  end
end
