class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|

      t.references :team, index: true
      t.references :user, index: true
    end
  end
end
