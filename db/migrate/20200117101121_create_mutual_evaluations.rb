class CreateMutualEvaluations < ActiveRecord::Migration[6.0]
  def change
    create_table :mutual_evaluations do |t|

      t.references :user, index: true
      t.references :homework, index: true
      t.references :team, index: true
      t.references :target, index: true, foreign_key: { to_table: :users }
    end
    add_index :mutual_evaluations, %i[user_id target_id homework_id],
              unique: true, name: 'redundancy_check'

  end
end
