class AddFieldsToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference :messages, :chat, null: false, foreign_key: true
    add_reference :messages, :user, foreign_key: true

    add_column :messages, :content, :text
    add_column :messages, :role, :integer, default: 0
  end
end
