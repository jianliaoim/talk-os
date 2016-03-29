## team.syncOne

Sync one team and members from third-part applications, and finally return the joined team.

### Route
> POST /v2/teams/syncone

### Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | --------------- |
| refer          | String             | true     | Reference of third-part application's name  |
| sourceId       | String             | true     | Source id of third-part application's team  |

### Request
```
POST /v2/teams/syncone HTTP/1.1
{
    "refer": "teambition",
    "sourceId": "55f16521ddbd80be7b53d507"
}
```

### Response
```json
{
    "_id": "55f16522ddbd80be7b53d508",
    "name": "team1",
    "creator": "55f16521ddbd80be7b53d506",
    "__v": 0,
    "sourceId": "55f16521ddbd80be7b53d507",
    "updatedAt": "2015-09-10T11:10:26.140Z",
    "createdAt": "2015-09-10T11:10:26.140Z",
    "nonJoinable": false,
    "inviteCode": "89bb19c036",
    "color": "ocean",
    "hasUnread": false,
    "unread": 0,
    "inviteUrl": "http://localhost:7000/v2/via/89bb19c036",
    "_creatorId": "55f16521ddbd80be7b53d506",
    "id": "55f16522ddbd80be7b53d508"
}
```
