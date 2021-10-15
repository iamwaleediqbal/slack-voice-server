class SlackAuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :user_team, only: [:create, :send_to_slack]
  require 'base64'
  require 'fileutils'

  def call_back
    url = 'https://slack.com/api/oauth.v2.access'
    response = Faraday::Connection.new.post(url, {client_id: '812204735201.2325689472722', client_secret: "a50820369d2eeb30e49265b7dbad1fd8", code: params[:code]}) { |request| request.options.timeout = 25 }

    pp response.body
    create_user  JSON.parse(response.body)
    render json: JSON.parse(response.body)
  end

  def create
    dir =  FileUtils.mkdir_p "tmp/#{params[:sender].split("/")[2]}-#{ params[:user_id]}-#{params[:folder_name]}/"
    convert_dir =  FileUtils.mkdir_p "tmp/#{params[:sender].split("/")[2]}-#{ params[:user_id]}-#{params[:folder_name]}/converted"
    if @team && @user
        data = request.params["blob"]
        File.open("#{dir[0]}/#{data.original_filename}", 'wb') do |file|
          file.write(data.read)
        end
        unless data.original_filename.include?("webm")
          system "ffmpeg -y -hide_banner -i #{dir[0]}/#{data.original_filename} -c copy -c:a aac -movflags +faststart #{convert_dir[0]}/#{data.original_filename}"
          system "rm #{dir[0]}/#{data.original_filename}"
        end
      render json: :ok
    else
       render json: :unauthorized
    end
  end

  def send_to_slack
    begin
      convertor
      conn = Faraday.new(
            url: 'https://slack.com/',
            headers: {'Content-Type' => 'multipart/form-data' , "authorization" => "Bearer #{@user.access_token}"}
            ) do |f|
        f.request :multipart
      end
      # debugger
      payload = { channels:  params[:thread_channel].nil? ? params[:thread_channel] : params[:sender].split("/")[3], thread_ts: params[:thread_ts]}
      payload[:file] = @file
      response = conn.post('/api/files.upload', payload)

      pp "-------------------end send----------------------"
      pp Time.now

      pp response.body
      render json: :ok
    rescue
      pp "#"*200
      # pp e
      return  render json: :ok
    end
  end

  def convertor
      @extention = params[:mime_type].include?("video") ?  "mkv" : "webm"
      if @extention == "mkv"
        @dir = "tmp/#{params[:sender].split("/")[2]}-#{ params[:user_id]}-#{params[:folder_name]}/converted"
      else
        @dir = "tmp/#{params[:sender].split("/")[2]}-#{ params[:user_id]}-#{params[:folder_name]}"
      end

      sleep 0.6

      if @extention == "webm"
          system "for f in #{@dir}/*.#{@extention} ; do echo file \"${f##*/}\" >> #{@dir}/list.txt; done && ffmpeg -f concat -safe 0 -i #{@dir}/list.txt -c copy #{@dir}/message.#{@extention} && rm #{@dir}/list.txt"
        system "ffmpeg -y -i #{@dir}/message.#{@extention} -ab 6400  #{@dir}/message.mp3"
        @file = Faraday::FilePart.new("#{@dir}/message.mp3", 'mp3')
      else
        system "for f in #{@dir}/*.#{@extention} ; do echo file \"${f##*/}\" >> #{@dir}/list.txt; done && ffmpeg -f concat -safe 0 -i #{@dir}/list.txt -c:v copy -c:a aac #{@dir}/message.#{@extention} && rm #{@dir}/list.txt"
         @file = Faraday::FilePart.new("#{@dir}/message.mkv", 'mkv')
      end

  end

  def user_team
      @team  = Team.find_by(slack_id: params[:sender].split("/")[2]) if params[:sender]
      return render json: :unauthorized unless @team
      @user = @team.users.find_by(slack_user_id: params[:user_id])
  end


  def create_user response
    return unless response && response["team"]
    team = Team.find_or_create_by(slack_id: response["team"]["id"])
    @user = SlackUser.find_or_create_by(slack_user_id: response["authed_user"]["id"], team_id: team.id, access_token: response["authed_user"]["access_token"])
    team = team.update(
        slack_name: response["team"]["name"],
        bot_user_id: response["bot_user_id"],
        bot_access_token: response["access_token"],
        scope: response["scope"],
        enterprise: response["enterprise"],
      )
    @user.update(
        scope: response["authed_user"]["scope"],
        avatar: get_avatar["profile"]["image_192"],
        name: get_avatar["profile"]["real_name"],
      )
    get_conversations
    get_members
    get_conversation_members
  end

  def get_avatar
    conn = Faraday.new(
    url: 'https://slack.com/',
    headers: {'Content-Type' => 'application/json', "authorization" => "Bearer #{@user.access_token}"}
    )
    response = conn.get('/api/users.profile.get')
    JSON.parse response.body
  end


  def get_conversations
    conn = Faraday.new(
    url: 'https://slack.com/',
    headers: {'Content-Type' => 'application/json', "authorization" => "Bearer #{@user.access_token}"}
    )
    response = conn.get('/api/conversations.list?types=public_channel,private_channel,mpim,im')
    res = JSON.parse response.body
    @conversations = []
    res["channels"].each do |channel|

      conversation = Conversation.find_or_create_by(
        conversation_id: channel["id"],
        team_id: @user.team_id,
        slack_user_id: @user.id
      )
      if channel["is_channel"].nil?
       conversation.update(
        conversation_user_id: channel["user"],
        is_archived: channel["is_archived"],
        is_user_deleted: channel["is_user_deleted"],
        )
     else
       conversation.update(
        is_archived: channel[:is_archived],
        is_user_deleted: channel[:is_user_deleted],
        is_channel: channel[:is_channel],
        is_group: channel[:is_group],
        is_member: channel[:is_member],
        is_private: channel[:is_private],
        creator_id: channel[:creator_id],
        name: channel[:name],
        last_read: channel[:last_read],
        )
     end
     @conversations << conversation
    end
  end

  def get_members
    conn = Faraday.new(
    url: 'https://slack.com/',
    headers: {'Content-Type' => 'application/json', "authorization" => "Bearer #{@user.access_token}"}
    )
    response = conn.get('/api/users.list')
    res = JSON.parse response.body
    # pp res["members"]
    res["members"].each do |mem|
     member = Member.find_or_create_by(
      team_id: @user.team_id,
      member_id: mem["id"]
      )
     member.update(
      name: mem["profile"]["real_name"],
      avatar: mem["profile"]["image_192"],
      is_owner: mem["is_owner"],
      is_admin: mem["is_admin"],
      is_app_user: mem["is_app_user"],
      is_deleted: mem["deleted"],
      )
    end
  end

end

  def get_conversation_members
    @conversations.each do |conversation|
      conn = Faraday.new(
      url: 'https://slack.com/',
      headers: {'Content-Type' => 'application/json', "authorization" => "Bearer #{@user.access_token}"}
      )
      response = conn.get("/api/conversations.members?channel=#{conversation.conversation_id}")
      res = JSON.parse response.body

      res["members"].each do |mem|
        unless conversation.members.include?(Member.find_by(member_id: mem))
          conversation.members <<  Member.find_by(member_id: mem)
        end
      end

    end
  end




