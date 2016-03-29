# 绑定第三方账号

> POST /v1/union/bind/:refer

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |
| code           | String             | true     | 合作网站返回的 code，根据 OAuth 版本参数名可能有区别 |

## 响应

```json
{
  "__v": 0,
  "name": "测试用户",
  "_id": "55ed37ae641943fca66ecfb4",
  "updatedAt": "2015-09-07T07:07:26.726Z",
  "createdAt": "2015-09-07T07:07:26.726Z",
  "wasNew": true,
  "id": "55ed37ae641943fca66ecfb4",
  "openId": "55ed1e3aaa6373be1e9fd60a",
  "refer": "teambition",
  "accountToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6InRlYW1iaXRpb24iLCJfaWQiOiI1NWVkMzdhZTY0MTk0M2ZjYTY2ZWNmYjQiLCJleHAiOjE0NDQyMDE2NDZ9.iG9TBehiRvpRxR_95eB-nx4v2gnvIGCKdv79fqGpJ7U"
}
```

> 如第三方账号已被其他账号绑定，则返回错误信息和 bindCode，供强制绑定

## 响应

```json
{
  "code": 230,
  "message": "绑定账号已存在",
  "data": {
    "bindCode": "EJ-QOEVPa"
  }
}
```
