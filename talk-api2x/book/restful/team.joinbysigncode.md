# team.joinbysigncode

Join team by signCode

### Route
> POST /v2/teams/:_id/joinbysigncode

## Params
| key        | type   | required | description      |
|------------|--------|----------|------------------|
| signCode   | String | true     | Team sign code |

## Request
```
POST /v2/teams/5655560714d3d44b48637ea6/joinbysigncode HTTP/1.1
Content-Type: application/json
{
  "signCode": "ee051df05r",
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
  "signCode": "534def2012",
  "color": "ocean",
  "hasUnread": false,
  "inviteUrl": "http://localhost:7000/v2/via/534def2012",
  "_creatorId": "5655560714d3d44b48637ea4",
  "id": "5655560714d3d44b48637ea6"
}
```
