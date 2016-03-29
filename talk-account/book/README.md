简聊账号系统 API 文档
===

# 账号信息

```json
{
  "name": "张三",                         // 用户姓名
  "avatarUrl": "http://xxx.com/xxx.png", // 用户头像
  "wasNew": true,                        // 是否新注册用户
  "login": "mobile",                     // 登录方式
  "accountToken": "xxxxxxxxx.yyyyyyyy",  // 账号口令
  "phoneNumber": "",                     // 手机号码
  "emailAddress": "",                    // 邮箱地址
  "openId": "xxxxxxxxxxxxx",             // 如果由第三方网站登录，则出现合作网站用户 ID
  "refer": "teambition"                  // 合作网站代号
}
```
