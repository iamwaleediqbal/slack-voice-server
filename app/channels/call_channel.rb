class CallChannel < ApplicationCable::Channel

  def self.for_token(token:)
    "CallChannel_#{token}"
  end

  def subscribed
    stream_from CallChannel.for_token( token: token_param )
  end

  private

  def token_param
    params[:room]
  end
end




