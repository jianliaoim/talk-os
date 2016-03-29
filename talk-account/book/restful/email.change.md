# 更换邮箱

> POST /v1/email/change

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| randomCode    | String             | true     | 随机口令，由 /v1/email/sendverifycode 接口生成 |
| verifyCode    | String             | true     | 验证码，发送至手机 |

## 响应

```json
{
  "_id": "564b078f871487fb4c8f768b",
  "__v": 0,
  "updatedAt": "2015-11-17T10:55:11.616Z",
  "createdAt": "2015-11-17T10:55:11.614Z",
  "emailAddress": "lurenjia@teambition.com",
  "unions": [],
  "login": "email",
  "wasNew": false,
  "accountToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6ImVtYWlsIiwiX2lkIjoiNTY0YjA3OGY4NzE0ODdmYjRjOGY3NjhiIiwiZXhwIjoxNDUwMzQ5NzEyfQ.YQibEv7Q1qSRgZTvz4BGFkbhYA1bkahp-U6hCz3J640",
  "id": "564b078f871487fb4c8f768b"
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
    "showname": "xxx@aaa.com"
  }
}
```
