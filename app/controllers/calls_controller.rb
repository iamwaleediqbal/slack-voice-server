class CallsController < ApplicationController
  def create
    head :no_content
    members = Conversation.find_by(conversation_id: params[:conversation])&.members.map{|m| m.member_id} if  params[:conversation]
    data = params[:conversation] ? call_params.merge(member_ids: members) : call_params
    ActionCable.server.broadcast("CallChannel_#{params[:room]}", data)
  end
  private

  def call_params
    params.permit( :type, :from, :to, :room, :sdp, :call, :channel)
  end
end
