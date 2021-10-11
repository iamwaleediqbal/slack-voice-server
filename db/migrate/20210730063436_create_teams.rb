class CreateTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :teams do |t|
      t.string :slack_id
      t.string :slack_name
      t.string :bot_user_id
      t.string :bot_access_token
      t.string :scope
      t.string :enterprise
      t.timestamps
    end
  end
end
