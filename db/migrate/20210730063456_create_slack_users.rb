class CreateSlackUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :slack_users do |t|
      t.string :slack_user_id
      t.string :scope
      t.string :access_token
      t.references :team, null: false, foreign_key: true
      t.timestamps
    end
  end
end
