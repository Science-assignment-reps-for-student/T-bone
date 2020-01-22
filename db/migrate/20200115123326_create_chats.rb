class CreateChats < ActiveRecord::Migration[6.0]
  def change
    create_table :chats do |t|

      t.references :user, index: true
      t.string :chat_message, null: false
      t.bigint :created_at, null: false
    end
  end
end
