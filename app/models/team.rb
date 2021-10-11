class Team < ApplicationRecord
  has_many :users, class_name: "SlackUser"
  has_many :conversations
end
