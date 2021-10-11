class Member < ApplicationRecord
  belongs_to :team
  has_many :conversation_members
  has_many :conversations, through: :conversation_members
end
