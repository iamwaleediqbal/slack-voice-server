class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.string :member_id
      t.string :name
      t.string :avatar
      t.boolean :is_owner
      t.boolean :is_admin
      t.boolean :is_app_user
      t.boolean :is_deleted
      t.string :timestamps
      t.references :team, null: false, foreign_key: true
    end
  end
end
