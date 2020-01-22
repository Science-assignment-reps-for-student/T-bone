class CreateSelfEvaluations < ActiveRecord::Migration[6.0]
  def change
    create_table :self_evaluations do |t|

      t.references :user, index: true
      t.references :homework, index: true
      t.references :team, index: true
      t.integer :scientific_accuracy, null: false
      t.integer :communication, null: false
      t.integer :attitude, null: false
    end
  end
end
