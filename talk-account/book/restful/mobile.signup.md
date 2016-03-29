# 手机注册

> POST /v1/mobile/signup

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| phoneNumber    | String             | true     | 手机号码，国外手机号必须带区号信息 |
| randomCode    | String              | true     | 随机口令，由 /v1/mobile/sendverifycode 接口生成 |
| verifyCode    | String              | true     | 验证码，发送至手机 |

## 响应

```json
{
  "_id": "55ee447284681a78d3e861b5",
  "name": "18500000000",
  "phoneNumber": "18500000000",
  "__v": 0,
  "updatedAt": "2015-09-08T02:14:10.688Z",
  "createdAt": "2015-09-08T02:14:10.556Z",
  "wasNew": false,
  "id": "55ee447284681a78d3e861b5",
  "accountToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6Im1vYmlsZSIsIl9pZCI6IjU1ZWU0NDcyODQ2ODFhNzhkM2U4NjFiNSIsImV4cCI6MTQ0NDI3MDQ1MH0.IbpXxTJ8QVqTusRp6ey6O3cWYTi6jsL0OhDIxSL3X8A"
}
```
