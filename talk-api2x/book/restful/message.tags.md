# message.tags

Get messages with tags

## Route
> GET /v2/messages/tags

## Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| _teamId        | ObjectId           | true     | Team id    |
| _tagId         | ObjectId           | false    | Tag id    |
| _maxId         | ObjectId           | false    | Read the messages before this id, the messages will sort desc by _id      |
| limit          | Number             | false    | Limitation |

## Request
```
GET /v2/messages/tags HTTP/1.1
```

## Response
```json
[
  {
    "_id": "569e1f7df4bd2665186761d4",
    "body": "hello",
    "team": "569e1f7df4bd2665186761c0",
    "room": {
      "_id": "569e1f7df4bd2665186761ce",
      "email": "room1.rbbb4c7e046@mail.jianliao.com",
      "team": "569e1f7df4bd2665186761c0",
      "topic": "room1",
      "py": "room1",
      "pinyin": "room1",
      "creator": "569e1f7cf4bd2665186761be",
      "guestToken": "bbb452b0",
      "__v": 0,
      "updatedAt": "2016-01-19T11:35:25.787Z",
      "createdAt": "2016-01-19T11:35:25.787Z",
      "memberCount": 2,
      "pys": [
        "room1"
      ],
      "pinyins": [
        "room1"
      ],
      "isGuestVisible": false,
      "color": "blue",
      "isPrivate": false,
      "isArchived": false,
      "isGeneral": false,
      "popRate": 6,
      "guestUrl": "http://guest.talk.bi/rooms/bbb452b0",
      "_creatorId": "569e1f7cf4bd2665186761be",
      "_teamId": "569e1f7df4bd2665186761c0",
      "id": "569e1f7df4bd2665186761ce"
    },
    "creator": {
      "_id": "569e1f7cf4bd2665186761be",
      "name": "dajiangyou1",
      "py": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "emailForLogin": "user1@teambition.com",
      "emailDomain": "teambition.com",
      "__v": 0,
      "unions": [],
      "updatedAt": "2016-01-19T11:35:24.905Z",
      "createdAt": "2016-01-19T11:35:24.903Z",
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
      "id": "569e1f7cf4bd2665186761be",
      "email": "user1@teambition.com"
    },
    "__v": 1,
    "tags": [
      {
        "_id": "569e1f7df4bd2665186761d3",
        "creator": "569e1f7cf4bd2665186761be",
        "name": "ok",
        "team": "569e1f7df4bd2665186761c0",
        "__v": 0,
        "updatedAt": "2016-01-19T11:35:25.861Z",
        "createdAt": "2016-01-19T11:35:25.860Z",
        "_creatorId": "569e1f7cf4bd2665186761be",
        "_teamId": "569e1f7df4bd2665186761c0",
        "id": "569e1f7df4bd2665186761d3"
      }
    ],
    "urls": [],
    "updatedAt": "2016-01-19T11:35:25.905Z",
    "createdAt": "2016-01-19T11:35:25.905Z",
    "displayType": "text",
    "icon": "normal",
    "isSystem": false,
    "attachments": [],
    "mentions": [],
    "type": "room",
    "_targetId": "569e1f7df4bd2665186761ce",
    "_teamId": "569e1f7df4bd2665186761c0",
    "_roomId": "569e1f7df4bd2665186761ce",
    "_creatorId": "569e1f7cf4bd2665186761be",
    "id": "569e1f7df4bd2665186761d4"
  }
]
```
