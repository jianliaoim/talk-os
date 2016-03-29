## team.refresh

### summary
Refresh the invitecode and inviteurl of team. Only admins and owners can send this request


### method
POST

### route
> /v2/teams/:_id/refresh

### events
* [team:update](../event/team.update.html)

### params
| key            | type               | required | description                                                  |
| -------------- | ------------------ | -------- | ------------------------------------------------------------ |
| properties     | Object             | true     | inviteCode, signCode, or other properties could be refreshed |

### request
```
POST /v2/teams/536c99d0460682621f7ea6e5/refresh HTTP/1.1
{
  "properties": {
    "inviteCode": 1,
    "signCode": 1
  }
}
Content-Type: application/json
```

### response
```json
{
  "_id": "5577ecb0671c6a43502b63b0",
  "name": "team1",
  "creator": "5577ecb0671c6a43502b63ae",
  "__v": 0,
  "updatedAt": "2015-06-10T07:52:16.393Z",
  "createdAt": "2015-06-10T07:52:16.036Z",
  "nonJoinable": false,
  "inviteCode": "9ce2af904o",
  "color": "ocean",
  "signCodeExpireAt": "2015-06-17T07:52:16.432Z",
  "signCode": "9ce8a3005i",
  "inviteUrl": "http://localhost:7000/v2/via/9ce2af904o",
  "_creatorId": "5577ecb0671c6a43502b63ae",
  "id": "5577ecb0671c6a43502b63b0"
}
```
