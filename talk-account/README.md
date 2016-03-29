talk-account
===
talk-account

# TODO

* 限制接口访问次数（增加 ratelimit 模块）
* 生成用户头像，或将第三方头像转换为 striker 地址

# 第三方登录

1. 跳转第三方网站授权页，获取 code 返回
2. 通过 code 获取 access_token，openId，与本地数据库匹配，如存在则直接登录，如不存在则创建用户
3. 登录/注册/授权

### Locales

前端使用 `/client/locales/` 目录下的多语言, `/locales/` 目录被服务端引用, 部分字段已经废弃.

### Develop

* dev

```bash
gulp dev # start webpack dev server
NODE_ENV=dev DEBUG=talk:* coffee app.coffee
```

* static, ws, ga...

```bash
NODE_ENV=static gulp build
NODE_ENV=static coffee app.coffee
```

### Routes

```coffee
module.exports = routerUtil.expandRoutes [
  ['signin', '/signin']
  ['signin', '/access']
  ['signin', '/']
  ['signup', '/signup']
  ['forgot-password', '/forgot-password']
  ['reset-password', '/reset-password'] #?resetToken=:code
  ['succeed-resetting', '/succeed-resetting']
  ['email-sent', '/email-sent']
  ['bind-mobile', '/bind-mobile'] # ?action=change
  ['bind-thirdparty', '/union/callback/:refer'] # ?code=:code
  ['bind-email', '/bind-email'] # ?next_url=:url
  ['verify-email', '/verify-email'] # ?action=:method&verifyToken=:code
  ['succeed-binding', '/succeed-binding']
  ['accounts', '/user/accounts']
  ['404', '~']
]
# urls generated in Email or third party account systems
generatedRoutes = ['reset-password', 'bind-thirdparty', 'verify-email']
```

### Debugging mode

增加参数, 用于在控制台打印邀请码和邮件, 同时关闭短信和邮件发送的代码:

```bash
NODE_ENV=dev DEBUG=talk:* coffee app.coffee
```
