class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|

      t.references :leader, index: true, foreign_key: { to_table: :users }
      t.references :homework, index: true
      t.string :team_name
    end
    add_index :teams, %i[homework_id team_name],
              unique: true
  end
end
