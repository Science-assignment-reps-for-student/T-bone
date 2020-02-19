class DestroyTeamId < ActiveRecord::Migration[6.0]
  def change
    remove_column :mutual_evaluations, :team_id
  end
end
