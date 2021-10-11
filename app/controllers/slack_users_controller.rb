class SlackUsersController < ApplicationController

  def show
    @user = SlackUser.find_by(slack_user_id: params[:id])
    @img = @user.avatar
  end
end
