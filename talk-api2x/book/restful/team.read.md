## team.read
Read a list of team that visible to the user.
User will automatically join teams through inviteCode in cookies or invitations by other people.

### Route
> GET /v2/teams

### Params
| key            | type               | required | description                                                  |
| -------------- | ------------------ | -------- | ------------------------------------------------------------ |

### Request
```
GET /v2/teams HTTP/1.1
```

### Response
```json
[
  {
    "_id": "5684959131697e125543976d",
    "name": "team1",
    "creator": "5684959131697e125543976b",
    "__v": 0,
    "updatedAt": "2015-12-31T02:40:17.262Z",
    "createdAt": "2015-12-31T02:40:17.262Z",
    "nonJoinable": false,
    "inviteCode": "d3aef8e0xi",
    "color": "ocean",
    "signCodeExpireAt": "2016-01-07T02:40:17.697Z",
    "signCode": "d3f159101c",
    "prefs": {
      "isMute": false,
      "hideMobile": false
    },
    "hasUnread": false,
    "unread": 0,
    "inviteUrl": "http://localhost:7000/page/invite/d3aef8e0xi",
    "_creatorId": "5684959131697e125543976b",
    "id": "5684959131697e125543976d"
  },
  {
    "_id": "5684959131697e125543976e",
    "name": "team2",
    "creator": "5684959131697e125543976b",
    "__v": 0,
    "updatedAt": "2015-12-31T02:40:17.264Z",
    "createdAt": "2015-12-31T02:40:17.264Z",
    "nonJoinable": false,
    "inviteCode": "d3af47001y",
    "color": "ocean",
    "signCodeExpireAt": "2016-01-07T02:40:17.697Z",
    "signCode": "d3f159114o",
    "prefs": {
      "isMute": false,
      "hideMobile": false
    },
    "hasUnread": false,
    "unread": 0,
    "inviteUrl": "http://localhost:7000/page/invite/d3af47001y",
    "_creatorId": "5684959131697e125543976b",
    "id": "5684959131697e125543976e"
  },
  {
    "_id": "5684959131697e1255439781",
    "name": "team3",
    "creator": "5684959131697e125543976c",
    "__v": 0,
    "updatedAt": "2015-12-31T02:40:17.415Z",
    "createdAt": "2015-12-31T02:40:17.415Z",
    "nonJoinable": false,
    "inviteCode": "d3c651711j",
    "color": "ocean",
    "signCodeExpireAt": "2016-01-07T02:40:17.697Z",
    "signCode": "d3f159126z",
    "prefs": {
      "isMute": false,
      "hideMobile": false
    },
    "hasUnread": false,
    "unread": 0,
    "inviteUrl": "http://localhost:7000/page/invite/d3c651711j",
    "_creatorId": "5684959131697e125543976c",
    "id": "5684959131697e1255439781"
  }
]
```
