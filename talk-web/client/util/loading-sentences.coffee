exports.list = list =
  '2016/4/1': [
    '这不是简聊'
    '简聊今天不上班'
    '简聊今天可能加载不出来了'
    '简聊要上市了'
    '感谢简聊上亿用户的支持'
    '简聊不小心把服务器关了， 马上就好'
    '公司国外友人看不懂这条加载消息'
  ]
  'others': [
    '简聊正在努力加载中'
    '简聊正在疯狂的敲着键盘把数据加载出来'
    '简聊正在努力思考午饭吃什么'
    '这个加载页面其实是用来考验你的耐心的'
    '简聊泡咖啡去了， 马上就来给你加载完'
    '简聊正在思考一条有意思的加载消息'
    '简聊正在下载内存中'
    '又是忙碌的一天'
    '感谢您使用简聊 :-)'
    '简聊正在穿越中'
    '简聊正在鱼塘捕鱼'
    '简聊正在草丛里找bug'
    '怎么还没加载完'
    '(╯°□°）╯︵ ┻━┻'
  ]

exports.get = (date) ->
  hash = "#{date.getFullYear()}/#{date.getMonth() + 1}/#{date.getDate()}"
  sentences = list[hash] or list['others']
  sentences[date.getMinutes() % sentences.length]
