# 强制绑定邮箱

> POST /v1/email/forcebind

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| bindCode     | String             | true     | 随机口令，由 /v1/email/bind 接口生成 |

## 响应

```json
{
  "_id": "564b06e72fbdbaa44cf7c34f",
  "__v": 0,
  "updatedAt": "2015-11-17T10:52:23.151Z",
  "createdAt": "2015-11-17T10:52:23.150Z",
  "emailAddress": "lurenjia@teambition.com",
  "unions": [],
  "login": "email",
  "wasNew": false,
  "accountToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6ImVtYWlsIiwiX2lkIjoiNTY0YjA2ZTcyZmJkYmFhNDRjZjdjMzRmIiwiZXhwIjoxNDUwMzQ5NTQzfQ.kl1fSReN5-ZtJRfNt3bBbXmOgpqiYy5P31Fqko1xmTw",
  "id": "564b06e72fbdbaa44cf7c34f"
}
```
