class ConversationMember < ApplicationRecord
  belongs_to :conversation
  belongs_to :member
end
