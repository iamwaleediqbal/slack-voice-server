class SlackUser < ApplicationRecord
  belongs_to :team
  has_many :conversations
end
