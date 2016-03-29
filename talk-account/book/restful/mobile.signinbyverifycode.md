# 验证手机验证码并登录

> POST /v1/mobile/signinbyverifycode

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
|randomCode|String|true|随机口令，由 sendverifycode 接口生成|
|verifyCode|String|true|验证码，发送至邮箱|
|action|String|true|验证码用途，当发送重置密码验证码时 action=resetpassword|
## 响应

```json
{
  "_id":"563c05c6cd3ae44e20a1ead9",
  "__v":0,
  "updatedAt":"2015-11-06T01:43:34.861Z",
  "createdAt":"2015-11-06T01:43:34.861Z",
  "showname":"15700000000",
  "phoneNumber":"15700000000",
  "unions":[],
  "wasNew":false,
  "accountToken":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6Im1vYmlsZSIsIl9pZCI6IjU2M2MwNWM2Y2QzYWU0NGUyMGExZWFkOSIsImV4cCI6MTQ0OTM2NjIxNH0.W2ozo4xlRHtKYOBjHlNxDlWineTXWuG3Wm71RVZU8XM",
  "id":"563c05c6cd3ae44e20a1ead9"
}
```
