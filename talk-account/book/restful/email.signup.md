# 邮件注册

> POST /v1/email/signup

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| emailAddress   | String             | true     | 邮件地址 |
| password       | String             | true     | 注册密码 |

## 响应

```json
{
  "__v": 0,
  "_id": "56386d7434937f4d51457d70",
  "updatedAt": "2015-11-03T08:16:52.023Z",
  "createdAt": "2015-11-03T08:16:52.021Z",
  "emailAddress": "lurenjia@teambition.com",
  "unions": [],
  "wasNew": true,
  "accountToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6ImVtYWlsIiwiX2lkIjoiNTYzODZkNzQzNDkzN2Y0ZDUxNDU3ZDcwIiwiZXhwIjoxNDQ5MTMwNjEyfQ.6M62mYCsSuJ9CStINFifb1FBUEzajGtB2tXpLHPlbEY",
  "id": "56386d7434937f4d51457d70"
}
```
