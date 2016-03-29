# 强制绑定手机号

> POST /v1/mobile/forcebind

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| bindCode     | String             | true     | 随机口令，由 /v1/mobile/bind 接口生成 |

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
