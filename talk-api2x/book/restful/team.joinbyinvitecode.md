# team.joinbyinvitecode

- 检查inviteCode参数是否存在,如果不存在返回"缺少参数：inviteCode"
- 根据inviteCode查找对应的team, 如果不存在返回"未找到对象：team inviteCode #{inviteCode}"
- 判断登录账号是否存在于team list；如果没有需要在team中添加该user并且broadcast "team:join", "message:create"信息以及返回team对象；如果说账号已经在team list的话，直接返回team对象

### Route
> POST /v2/teams/joinbyinvitecode

## Params
| key        | type   | required | description      |
|------------|--------|----------|------------------|
| inviteCode | String | true     | Team invite code |

## Request
```
POST /v2/teams/joinbyinvitecode HTTP/1.1
Content-Type: application/json
{
  "inviteCode": "ee051df05r",
}
```

## Response
```json
{
  "_id": "5655560714d3d44b48637ea6",
  "name": "team1",
  "creator": "5655560714d3d44b48637ea4",
  "__v": 0,
  "updatedAt": "2015-11-25T06:32:39.954Z",
  "createdAt": "2015-11-25T06:32:39.954Z",
  "nonJoinable": false,
  "inviteCode": "534def2012",
  "color": "ocean",
  "hasUnread": false,
  "inviteUrl": "http://localhost:7000/v2/via/534def2012",
  "_creatorId": "5655560714d3d44b48637ea4",
  "id": "5655560714d3d44b48637ea6"
}
```
