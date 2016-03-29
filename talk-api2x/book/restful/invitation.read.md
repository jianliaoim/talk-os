# invitation.read

Get invitation list of a team

## Route
> GET /v2/invitations

## Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------- |
| _teamId        | ObjectId           | true     | Team id |

## request
```
GET /v2/invitations?_teamId=536c834d26faf71918b774ea HTTP/1.1
```

## response
```json
[
  {
    "_id": "567b57de10ef16c8b439d1ff",
    "mobile": "13011111111",
    "team": "567b57de10ef16c8b439d1dd",
    "room": "567b57de10ef16c8b439d1fa",
    "key": "mobile_13011111111",
    "name": "13011111111",
    "__v": 0,
    "updatedAt": "2015-12-24T02:26:38.813Z",
    "createdAt": "2015-12-24T02:26:38.813Z",
    "role": "member",
    "isInvite": true,
    "_teamId": "567b57de10ef16c8b439d1dd",
    "_roomId": "567b57de10ef16c8b439d1fa",
    "id": "567b57de10ef16c8b439d1ff"
  }
]
```
