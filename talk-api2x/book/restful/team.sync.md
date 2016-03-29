## team.sync
Sync teams and members from third-part applications, and finally return all the joined teams.

### Route
> POST /v2/teams/sync

### Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | --------------- |
| refer          | String             | true     | Reference of third-part application's name  |
| sourceIds      | String             | true     | Source id of third-part application's team  |

### Request
```
POST /v2/teams/sync?refer=teambition HTTP/1.1
```

### Response
```json
[
  {
    "_id": "55f16522ddbd80be7b53d508",
    "name": "team1",
    "creator": "55f16521ddbd80be7b53d506",
    "__v": 0,
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
  },
  {
    "_id": "55f16522ddbd80be7b53d509",
    "name": "team2",
    "creator": "55f16521ddbd80be7b53d506",
    "__v": 0,
    "updatedAt": "2015-09-10T11:10:26.142Z",
    "createdAt": "2015-09-10T11:10:26.142Z",
    "nonJoinable": false,
    "inviteCode": "89bb67e03g",
    "color": "ocean",
    "hasUnread": false,
    "unread": 0,
    "inviteUrl": "http://localhost:7000/v2/via/89bb67e03g",
    "_creatorId": "55f16521ddbd80be7b53d506",
    "id": "55f16522ddbd80be7b53d509"
  },
  {
    "_id": "55f16522ddbd80be7b53d53c",
    "name": "team3",
    "creator": "55f16521ddbd80be7b53d507",
    "__v": 0,
    "updatedAt": "2015-09-10T11:10:26.424Z",
    "createdAt": "2015-09-10T11:10:26.424Z",
    "nonJoinable": false,
    "inviteCode": "89e66f802k",
    "color": "ocean",
    "hasUnread": false,
    "unread": 0,
    "inviteUrl": "http://localhost:7000/v2/via/89e66f802k",
    "_creatorId": "55f16521ddbd80be7b53d507",
    "id": "55f16522ddbd80be7b53d53c"
  }
]
```
