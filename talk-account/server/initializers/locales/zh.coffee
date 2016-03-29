module.exports =
  NOT_FOUND: 'Not Found'
  OBJECT_MISSING: (msg = '') -> "对象不存在 #{msg}"
  PARAMS_INVALID: (msg = '') -> "错误的参数 #{msg}"
  PARAMS_MISSING: (msg = '') -> "缺少参数 #{msg}"
  RATE_LIMIT_EXCEEDED: "请求过于频繁"

  REQUEST_FAILED: '请求失败'
  VERIFY_FAILED: '验证失败'
  ACCESS_FAILED: '无权限访问'
  RESEND_TOO_OFTEN: '发送过于频繁'
  INVALID_SOURCE: (source) -> "错误的来源 #{source}"
  LOGIN_FAILED: "登录失败：%s"
  BIND_CONFLICT: "绑定账号已存在"
  PASSWORD_TOO_SIMPLE: "密码过于简单"
  LOGIN_VERIFY_FAILED: '登录失败，邮箱，手机号或密码错误'
  ACCOUNT_EXISTS: '账号已存在'
  INVALID_ACTION: '错误的 action 参数'
  ACCOUNT_NOT_EXIST: '账号不存在'
  SEND_SMS_ERROR: '发送短信失败'
  NO_PASSWORD: "账号尚未设置密码，请通过找回密码登录"
