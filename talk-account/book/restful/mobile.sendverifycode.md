# 发送手机验证码

> POST /v1/mobile/sendverifycode

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| phoneNumber    | String             | true     | 手机号码，国外手机号必须带区号信息 |
| action         | String             | false    | 验证码用途，当发送注册验证码时 action=signup，当发送重置密码时 action=resetpassword |
| password       | String             | false    | 密码，当 action=signup 时必须填写 |

## 响应

```json
{
  "randomCode": "4ybgj4Ah"
}
```
