# activity.read

Read a list of activities

## Route
> GET /v2/activities

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _teamId        | ObjectId           | true     | Team id        |
| _maxId         | ObjectId           | false    | Read activities before this id, the activities will sort by descending order of createdAt |
| maxDate        | Date               | false    | Read activities earlier than this date, the activities will sort by descending order of createdAt |
| minDate        | Date               | false    | Read activities later than this date, the activities will sort by ascending order of createdAt |
| limit          | Number             | false    | Limitation |

## Request
```json
GET /v2/activities?_teamId=536c99d0460682621f7ea6e5 HTTP/1.1
```

### Response
```json
[
  {
    "_id": "56a88196c1e894990e8df1ac",
    "team": "56a88196c1e894990e8df18e",
    "creator": {
      "_id": "56a88195c1e894990e8df18c",
      "name": "dajiangyou1",
      "py": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "emailForLogin": "user1@teambition.com",
      "emailDomain": "teambition.com",
      "__v": 0,
      "unions": [],
      "updatedAt": "2016-01-27T08:36:37.203Z",
      "createdAt": "2016-01-27T08:36:37.202Z",
      "isGuest": false,
      "isRobot": false,
      "pys": [
        "dajiangyou1"
      ],
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "avatarUrl": "null",
      "id": "56a88195c1e894990e8df18c",
      "email": "user1@teambition.com"
    },
    "text": "{{__info-invite-team-member}} tt",
    "__v": 0,
    "updatedAt": "2016-01-27T08:36:38.621Z",
    "createdAt": "2016-01-27T08:36:38.621Z",
    "members": [],
    "isPublic": true,
    "_creatorId": "56a88195c1e894990e8df18c",
    "_teamId": "56a88196c1e894990e8df18e",
    "id": "56a88196c1e894990e8df1ac"
  },
  {
    "_id": "56a88196c1e894990e8df1a3",
    "team": "56a88196c1e894990e8df18e",
    "target": {
      "_id": "56a88196c1e894990e8df1a1",
      "email": "newroom.r14f88b301e@mail.jianliao.com",
      "topic": "New room",
      "py": "new room",
      "pinyin": "new room",
      "creator": "56a88195c1e894990e8df18c",
      "team": "56a88196c1e894990e8df18e",
      "__v": 0,
      "updatedAt": "2016-01-27T08:36:38.369Z",
      "createdAt": "2016-01-27T08:36:38.369Z",
      "memberCount": 1,
      "pys": [
        "new room"
      ],
      "pinyins": [
        "new room"
      ],
      "isGuestVisible": true,
      "color": "blue",
      "isPrivate": false,
      "isArchived": false,
      "isGeneral": false,
      "popRate": 3,
      "_creatorId": "56a88195c1e894990e8df18c",
      "_teamId": "56a88196c1e894990e8df18e",
      "id": "56a88196c1e894990e8df1a1"
    },
    "type": "room",
    "creator": {
      "_id": "56a88195c1e894990e8df18c",
      "name": "dajiangyou1",
      "py": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "emailForLogin": "user1@teambition.com",
      "emailDomain": "teambition.com",
      "__v": 0,
      "unions": [],
      "updatedAt": "2016-01-27T08:36:37.203Z",
      "createdAt": "2016-01-27T08:36:37.202Z",
      "isGuest": false,
      "isRobot": false,
      "pys": [
        "dajiangyou1"
      ],
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "avatarUrl": "null",
      "id": "56a88195c1e894990e8df18c",
      "email": "user1@teambition.com"
    },
    "text": "{{__info-create-room}} New room",
    "__v": 0,
    "updatedAt": "2016-01-27T08:36:38.426Z",
    "createdAt": "2016-01-27T08:36:38.426Z",
    "members": [],
    "isPublic": true,
    "_creatorId": "56a88195c1e894990e8df18c",
    "_targetId": "56a88196c1e894990e8df1a1",
    "_teamId": "56a88196c1e894990e8df18e",
    "id": "56a88196c1e894990e8df1a3"
  }
]
```
