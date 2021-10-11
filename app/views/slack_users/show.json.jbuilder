json.user(render "slack_users/user", user: @user)
json.img(image: @img)
json.name(name: @user.name)
