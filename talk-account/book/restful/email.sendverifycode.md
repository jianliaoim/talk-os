# 发送邮箱验证码

> POST /v1/email/sendverifycode

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| emailAddress   | String             | true     | 已经存在用户的email   |
| action         | String             | true     | 发送验证码的操作（resetpassword,bind,change）   |

## 响应

```json
{
  "randomCode":"4Jzu8dkrze",
  "verifyCode":"4210"
}
```
