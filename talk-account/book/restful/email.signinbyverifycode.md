# 验证邮箱验证码

- 如果验证成功用户会自动登录

> POST /v1/email/signinbyverifycode

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| randomCode     | String             | true     | 随机口令，由 sendverifycode 接口生成 |
| verifyCode     | String             | true     | 验证码，发送至邮箱  |

> 如果点击邮箱验证链接访问，通过 resetToken 参数验证，不需要发送 randomCode,verifyCode

## 响应

```json
{
  "_id":"563bfa89565a348445d0279a",
  "__v":0,
  "updatedAt":"2015-11-06T00:55:37.546Z",
  "createdAt":"2015-11-06T00:55:37.546Z",
  "emailAddress":"lurenjia@teambition.com",
  "unions":[],
  "wasNew":false,
  "accountToken":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6ImVtYWlsIiwiX2lkIjoiNTYzYmZhODk1NjVhMzQ4NDQ1ZDAyNzlhIiwiZXhwIjoxNDQ5MzYzMzM3fQ.i5qMnAjnjn3QGevRTzmHnBa_XwT8vSAQFvmWocuprmk","id":"563bfa89565a348445d0279a"
}
```
