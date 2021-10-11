class Conversation < ApplicationRecord
  belongs_to :team
  belongs_to :slack_user
  has_many :conversation_members
  has_many :members, through: :conversation_members

end
