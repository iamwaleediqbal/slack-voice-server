class CreateConversations < ActiveRecord::Migration[6.1]
  def change
    create_table :conversations do |t|
      t.string  :conversation_id
      t.string  :conversation_user_id
      t.boolean :is_archived
      t.boolean :is_user_deleted
      t.boolean :is_channel
      t.boolean :is_group
      t.boolean :is_member
      t.boolean :is_private
      t.string  :name
      t.string  :creator_id
      t.string  :last_read
      t.references :team, null: false, foreign_key: true
      t.references :slack_user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
