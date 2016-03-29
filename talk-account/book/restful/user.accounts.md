# 读取所有绑定账号

`login` 字段表示账号来源和类型（mobile, teambition 等）

> GET /v1/user/accounts

| 参数            | 类型               | 是否必须  | 描述  |
| -------------- | ------------------ | -------- | ------------ |

## 响应

```json
[
  {
    "_id": "55eea609d953d145f75a27e5",
    "user": "55eea609d953d145f75a27e4",
    "phoneNumber": "18500000000",
    "__v": 0,
    "updatedAt": "2015-09-08T09:10:33.898Z",
    "createdAt": "2015-09-08T09:10:33.898Z",
    "login": "mobile",
    "id": "55eea609d953d145f75a27e5"
  },
  {
    "_id": "55eea609d953d145f75a27e6",
    "user": "55eea609d953d145f75a27e4",
    "accessToken": "abc",
    "name": "测试用户",
    "showname": "xxx@abc.com",
    "openId": "55ed1e3aaa6373be1e9fd60a",
    "refer": "teambition",
    "__v": 0,
    "updatedAt": "2015-09-08T09:10:33.966Z",
    "createdAt": "2015-09-08T09:10:33.965Z",
    "login": "teambition",
    "id": "55eea609d953d145f75a27e6"
  }
]
```
