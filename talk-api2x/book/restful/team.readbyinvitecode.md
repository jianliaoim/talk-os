# team.readbyinvitecode

## Route
> GET /v2/teams/readbyinvitecode

## Params
| key        | type   | required | description      |
|------------|--------|----------|------------------|
| inviteCode | String | true     | Team invite code |

## Request
```
GET /v2/teams/readbyinvitecode?inviteCode=ee051df05r HTTP/1.1
```

## Response
```json
{
  "_id": "5654247020d724ae25bf1ba6",
  "name": "team1",
  "creator": "5654247020d724ae25bf1ba4",
  "__v": 0,
  "updatedAt": "2015-11-24T08:48:48.091Z",
  "createdAt": "2015-11-24T08:48:48.091Z",
  "nonJoinable": false,
  "inviteCode": "2d7afab047",
  "color": "ocean",
  "hasUnread": false,
  "inviteUrl": "http://localhost:7000/v2/via/2d7afab047",
  "_creatorId": "5654247020d724ae25bf1ba4",
  "id": "5654247020d724ae25bf1ba6"
}
```
