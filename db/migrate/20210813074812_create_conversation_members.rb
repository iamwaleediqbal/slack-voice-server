class CreateConversationMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :conversation_members do |t|
      t.references :member, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true
      t.timestamps
    end
  end
end
