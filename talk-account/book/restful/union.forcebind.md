# 强制绑定第三方账号

> POST /v1/union/forcebind/:refer

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| bindCode     | String             | true     | 随机口令，由 /v1/union/bind/:refer 接口生成 |

## 响应

```json
{
  "_id": "55ee97aa778848f0eb7137ef",
  "__v": 0,
  "updatedAt": "2015-09-08T08:09:14.649Z",
  "createdAt": "2015-09-08T08:09:14.649Z",
  "name": "测试用户",
  "openId": "55ed1e3aaa6373be1e9fd60a",
  "refer": "teambition",
  "login": "teambition",
  "wasNew": false,
  "accountToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6InRlYW1iaXRpb24iLCJfaWQiOiI1NWVlOTdhYTc3ODg0OGYwZWI3MTM3ZWYiLCJleHAiOjE0NDQyOTE3NTR9.iYzV-SbO5cB4uWMGz5fJC-8gv6I2XKL-mFC33021LNQ",
  "id": "55ee97aa778848f0eb7137ef"
}
```
