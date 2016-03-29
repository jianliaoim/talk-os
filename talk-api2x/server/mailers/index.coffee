module.exports =
  inviteMailer: require './invite'
  loginMailer: require './login'
  rmMailer: require './room-message'
  dmMailer: require './direct-message'
  gmMailer: require './guest-message'
  smMailer: require './story-message'
