# 绑定邮箱

> POST /v1/email/bind

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| randomCode    | String             | true     | 随机口令，由 /v1/email/sendverifycode 接口生成 |
| verifyCode    | String             | true     | 验证码，发送至邮箱 |

> 如果点击邮箱验证链接访问，通过 verifyToken 参数验证，不需要发送 randomCode,verifyCode

## 响应

```json
{
  "_id": "564b0763d2361ee64ceb4418",
  "__v": 0,
  "updatedAt": "2015-11-17T10:54:27.209Z",
  "createdAt": "2015-11-17T10:54:27.208Z",
  "emailAddress": "lurenyi@jianliao.com",
  "unions": [],
  "login": "email",
  "wasNew": false,
  "accountToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6ImVtYWlsIiwiX2lkIjoiNTY0YjA3NjNkMjM2MWVlNjRjZWI0NDE4IiwiZXhwIjoxNDUwMzQ5NjY3fQ.IIrALl81x-T9Vor8esfbVlsQNoNTWNuZ3S09FRfwfIM",
  "id": "564b0763d2361ee64ceb4418"
}
```

> 如邮箱已被其他账号绑定，则返回错误信息和 bindCode，供强制绑定

## 响应

```json
{
  "code": 230,
  "message": "绑定账号已存在",
  "data": {
    "bindCode": "EJ-QOEVPa",
    "showname": "xxx@bbb.com"
  }
}
```
