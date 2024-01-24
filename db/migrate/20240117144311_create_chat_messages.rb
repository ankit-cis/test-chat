class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.text :content, limit: 65535
      t.string :role, default: "user"

      t.timestamps
    end
  end
end
