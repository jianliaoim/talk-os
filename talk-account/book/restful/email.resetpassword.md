# 通过邮箱重置密码

> POST /v1/email/resetpassword

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| newPassword    | String             | true      | 新密码  |

## 响应

```json
{
  "_id":"563bfbb0f8431d574fb22073",
  "__v":0,
  "updatedAt":"2015-11-06T01:00:32.360Z",
  "createdAt":"2015-11-06T01:00:32.360Z",
  "emailAddress":"lurenjia@teambition.com",
  "unions":[],
  "wasNew":false,
  "accountToken":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6ImVtYWlsIiwiX2lkIjoiNTYzYmZiYjBmODQzMWQ1NzRmYjIyMDczIiwiZXhwIjoxNDQ5MzYzNjMyfQ.ldAFAqi2PlSKNNg5Xnj5f1RcOVXr7FiAIg3-D_u9sh4","id":"563bfbb0f8431d574fb22073"
}
```
