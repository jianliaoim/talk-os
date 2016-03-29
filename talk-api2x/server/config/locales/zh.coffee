module.exports =
  DEFAULT_ERROR: '未知错误'
  CREATE_ERROR: (collection) -> "数据创建错误： #{collection}"
  UPDATE_ERROR: (collection) -> "数据更新错误： #{collection}"
  DELETE_ERROR: (collection) -> "数据删除错误： #{collection}"

  NOT_LOGIN: '用户未登录'
  INVALID_TOKEN: 'Token 错误，请重新登录'
  MISSING_UID: '缺少uid'
  MEMBER_CHECK_FAIL: (type) -> "非 #{type or ''} 成员"
  SYNC_TEAMBITION_FAIL: (type = '') -> "同步 teambition #{type}失败"

  # Privilege errors
  LANDING_FAIL: '登录失败'
  SOCKET_ID_ERROR: '错误的socketId或session已过期'
  SOCKET_ID_BROKEN: 'socketId数据不完整'
  CLIENT_ID_ERROR: 'clientId不正确'
  UNKNOWN_SYNC_SOURCE: '未知的同步源'
  INVALID_APPLICATION: '应用不存在'
  PASSWORD_ERROR: '密码或邮箱错误'
  MISSING_INTEGRATION_SOURCE: (source = '') -> "未找到同步源：#{source}"
  PROCESS_LOCKED: (key = '') -> "#{key} 已被锁定，请勿重复尝试"
  TEAM_LEAVE_ERROR: "退出团队失败"
  ALREADY_MEMBER: "已存在团队成员"
  INVALID_INVITECODE: "错误的邀请码"
  INVALID_OBJECT: (args...) -> "错误的对象： #{args.join(', ')}"
  NO_PERMISSION: '无访问权限'
  TOKEN_EXPIRED: '你的登录已过期，请重新登录'
  NOT_EDITABLE: (fields...) -> "以下属性不可编辑：#{fields.join(', ')}"
  ROOM_IS_ARCHIVED: "话题已被归档"
  SIGNATURE_FAILED: "签名校验错误"
  REQUEST_FAILD: "请求失败"
  NOT_ACCESSIBLE_FOR_GUEST: "无访客权限"
  FILE_SAVE_FAILED: "保存文件失败"
  FILE_MISSING: "缺少文件"
  GUEST_MODE_DISABLED: '访客模式已关闭'
  PARAMS_OUT_OF_SIZE: (args...) -> "参数 #{args} 超出长度"
  SEARCH_FAILED: '搜索请求失败'
  OUT_OF_SEARCH_RANGE: '超出搜索范围'
  RATE_LIMIT_EXCEEDED: '请求过于频繁'
  NOT_TEAMBITION_USER: "非 Teambition 用户"
  NOT_PRIVATE_ROOM: "非私有话题无法删除成员"
  INVALID_MSG_TOKEN: "错误的消息口令"
  INVITATION_EXISTING: "邀请记录已存在"
  TOO_MANY_FIELDS: "参数值数量超过限制"
  MEMBER_EXISTING: "成员已存在"
  VOIP_REQUEST_FAILD: (msg) -> "创建语音账号失败 #{msg}"
  PROPERTY_EXISTING: (prop) -> "#{prop} 属性已存在"
  INVALID_ACCESS_TOKEN: "错误的访问口令"
  INVALID_OPERATION: (msg) -> "操作不可执行：#{msg or ''}"
  INVALID_REFER: "错误的同步来源"
  PUSH_FAILED: "消息推送失败 %s"
  INVALID_MAKR_TARGET: "此对象不可标记"
  NAME_CONFLICT: "该名称已存在"
  CAN_NOT_ADD_INTEGRATION_IN_OFFICIAL_ROOMS: "这是一个公开的团队，请勿在此添加聚合服务"
  INTEGRATION_ERROR: '聚合数据出现错误： %s'
  INTEGRATION_ERROR_DISABLED: '你的聚合服务因为错误次数过多而被停用，如需重新启用，请修改服务配置。错误信息：%s'
  MOBILE_RATE_EXCEEDED: "发送短信次数超过限制"
  SEND_SMS_ERROR: '短信发送错误'
  BAD_REQUEST: "请求失败"

  # Common errors
  PARAMS_MISSING: (args...) -> "缺少参数： #{args.join(', ')}"
  OBJECT_MISSING: (args...) -> "未找到对象： #{args.join(', ')}"
  OBJECT_EXISTING: (args...) -> "对象已存在：#{args.join(', ')}"
  CLIENT_MISSING: (args...) -> "未发现客户端： #{args.join(', ')}"
  PARAMS_INVALID: (args...) -> "无效的参数： #{args.join(', ')}"
  INVALID_TARGET: (args...) -> "错误的对象： #{args.join(', ')}"
  FIELD_MISSING: (args...) -> "缺少属性： #{args.join(', ')}"
  PARAMS_CONFLICT: (args...) -> "参数冲突：#{args.join(', ')}"
  FUNCTION_MISSING: (args...) -> "缺少方法： #{args.join(', ')}"
  CONFIG_MISSING: "缺少配置文件 %s"

  # Application errors
  MESSAGE_NOT_EDITABLE: "消息不可编辑"
  MESSAGE_STRUCTURE_ERROR: "消息结构错误"
  INVALID_SERVICE: "不存在的聚合类型"
  INVALID_RSS_URL: "不是有效的 RSS 链接"

  ########################## Define functions ##########################
  inteErrorMessage: (integration, topic = '') ->
    """
    聚合内容出现错误，请查看后重新配置。
    聚合类型：#{integration.category}
    错误信息：#{integration.errorInfo}
    绑定话题：#{topic}
    """

  mentionOutOfRoom: (creatorUser, room) ->
    util = require '../../util'
    [
      "#{creatorUser.prefs?.alias or creatorUser.name} 在话题 "
      "<$link|#{util.buildTeamUrl room._teamId, room._id}|##{room.topic}$>"
      " 里面提到了你"
    ].join ''

  inviteSMS: (inviterName, teamName, inviteLink) ->
    "#{inviterName} 邀请你加入 #{teamName} 团队，点击 #{inviteLink} 用手机号登录即可加入团队（若已有帐号请绑定手机号）。[简聊]"

  welcomeNewTeamMember: (team) ->
    msg = "你好，欢迎加入#{team.name}，在这里你可以与团队成员分享文件，想法和链接，并在不同的话题中参与讨论，「简聊」起来吧。"
    msg += "\n" + team.description if team.description?.length
    msg
