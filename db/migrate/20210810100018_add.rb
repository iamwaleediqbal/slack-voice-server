class Add < ActiveRecord::Migration[6.1]
  def change
    add_column :slack_users, :avatar, :string
    add_column :slack_users, :name, :string
  end
end
