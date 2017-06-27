module.exports =
  # Listening port and sockjs prefix
  port: process.env.PORT or 7001
  prefix: '/snapper/socket'
  # Configure redis pub/sub instance and channel prefix
  pub: [6379, "10.10.10.1"]
  sub: [6379, "10.10.10.1"]
  channelPrefix: 'snapper'
