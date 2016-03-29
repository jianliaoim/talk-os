# message.mentions

Retrive the messages of @me and @all

## Route
> GET /v2/messages/mentions

## Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| _teamId        | ObjectId           | true     | Team id    |
| _roomId        | ObjectId           | false    | Room id  |
| _storyId       | ObjectId           | false    | Story id |
| _toId/_withId  | ObjectId           | false    | Target user id |
| _maxId         | ObjectId           | false    | Read the messages before this id, the messages will sort desc by _id      |
| limit          | Number             | false    | Limitation |

## Request
```
GET /v2/messages/mentions HTTP/1.1
```

## Response
```json
[
  {
    "_id": "56948c20f62a0aa571f3e2e9",
    "body": "<$at|all|@\u6240\u6709\u6210\u5458$> hello",
    "team": "56948c1ff62a0aa571f3e2d5",
    "room": {
      "_id": "56948c20f62a0aa571f3e2e3",
      "email": "room1.r9ae8edd06s@mail.jianliao.com",
      "team": "56948c1ff62a0aa571f3e2d5",
      "topic": "room1",
      "py": "room1",
      "pinyin": "room1",
      "creator": "56948c1ff62a0aa571f3e2d3",
      "guestToken": "9ae85190",
      "__v": 0,
      "updatedAt": "2016-01-12T05:16:16.041Z",
      "createdAt": "2016-01-12T05:16:16.041Z",
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
      "guestUrl": "http:\/\/guest.talk.bi\/rooms\/9ae85190",
      "_creatorId": "56948c1ff62a0aa571f3e2d3",
      "_teamId": "56948c1ff62a0aa571f3e2d5",
      "id": "56948c20f62a0aa571f3e2e3"
    },
    "creator": {
      "_id": "56948c1ff62a0aa571f3e2d4",
      "name": "dajiangyou2",
      "py": "dajiangyou2",
      "pinyin": "dajiangyou2",
      "emailForLogin": "user2@teambition.com",
      "emailDomain": "teambition.com",
      "__v": 0,
      "unions": [

      ],
      "updatedAt": "2016-01-12T05:16:15.418Z",
      "createdAt": "2016-01-12T05:16:15.418Z",
      "isGuest": false,
      "isRobot": false,
      "pys": [
        "dajiangyou2"
      ],
      "pinyins": [
        "dajiangyou2"
      ],
      "from": "register",
      "avatarUrl": "null",
      "email": "user2@teambition.com",
      "id": "56948c1ff62a0aa571f3e2d4"
    },
    "__v": 0,
    "tags": [

    ],
    "urls": [

    ],
    "updatedAt": "2016-01-12T05:16:16.160Z",
    "createdAt": "2016-01-12T05:16:16.160Z",
    "displayType": "text",
    "icon": "normal",
    "isSystem": false,
    "attachments": [

    ],
    "mentions": [
      "56948c1ff62a0aa571f3e2d3",
      "56948c1ff62a0aa571f3e2d4"
    ],
    "type": "room",
    "_targetId": "56948c20f62a0aa571f3e2e3",
    "_teamId": "56948c1ff62a0aa571f3e2d5",
    "_roomId": "56948c20f62a0aa571f3e2e3",
    "_creatorId": "56948c1ff62a0aa571f3e2d4",
    "id": "56948c20f62a0aa571f3e2e9"
  },
  {
    "_id": "56948c20f62a0aa571f3e2e8",
    "body": "message <$at|56948c1ff62a0aa571f3e2d3|@dajiangyou1$> hello",
    "team": "56948c1ff62a0aa571f3e2d5",
    "room": {
      "_id": "56948c20f62a0aa571f3e2e3",
      "email": "room1.r9ae8edd06s@mail.jianliao.com",
      "team": "56948c1ff62a0aa571f3e2d5",
      "topic": "room1",
      "py": "room1",
      "pinyin": "room1",
      "creator": "56948c1ff62a0aa571f3e2d3",
      "guestToken": "9ae85190",
      "__v": 0,
      "updatedAt": "2016-01-12T05:16:16.041Z",
      "createdAt": "2016-01-12T05:16:16.041Z",
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
      "guestUrl": "http:\/\/guest.talk.bi\/rooms\/9ae85190",
      "_creatorId": "56948c1ff62a0aa571f3e2d3",
      "_teamId": "56948c1ff62a0aa571f3e2d5",
      "id": "56948c20f62a0aa571f3e2e3"
    },
    "creator": {
      "_id": "56948c1ff62a0aa571f3e2d4",
      "name": "dajiangyou2",
      "py": "dajiangyou2",
      "pinyin": "dajiangyou2",
      "emailForLogin": "user2@teambition.com",
      "emailDomain": "teambition.com",
      "__v": 0,
      "unions": [

      ],
      "updatedAt": "2016-01-12T05:16:15.418Z",
      "createdAt": "2016-01-12T05:16:15.418Z",
      "isGuest": false,
      "isRobot": false,
      "pys": [
        "dajiangyou2"
      ],
      "pinyins": [
        "dajiangyou2"
      ],
      "from": "register",
      "avatarUrl": "null",
      "email": "user2@teambition.com",
      "id": "56948c1ff62a0aa571f3e2d4"
    },
    "__v": 0,
    "tags": [

    ],
    "urls": [

    ],
    "updatedAt": "2016-01-12T05:16:16.159Z",
    "createdAt": "2016-01-12T05:16:16.159Z",
    "displayType": "text",
    "icon": "normal",
    "isSystem": false,
    "attachments": [

    ],
    "mentions": [
      "56948c1ff62a0aa571f3e2d3"
    ],
    "type": "room",
    "_targetId": "56948c20f62a0aa571f3e2e3",
    "_teamId": "56948c1ff62a0aa571f3e2d5",
    "_roomId": "56948c20f62a0aa571f3e2e3",
    "_creatorId": "56948c1ff62a0aa571f3e2d4",
    "id": "56948c20f62a0aa571f3e2e8"
  }
]
```
