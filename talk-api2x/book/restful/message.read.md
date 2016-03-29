# message.read

Read the messages from room or between users

## Route
> GET /v2/messages

## Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| _roomId        | ObjectId           | false    | Room id  |
| _storyId       | ObjectId           | false    | Story id |
| _toId/_withId  | ObjectId           | false    | Target user id |
| _teamId        | ObjectId           | false    | Team id    |
| limit          | Number             | false    | Limitation |
| maxDate        | Date               | false    | Max created date |
| _maxId         | ObjectId           | false    | Read the messages before this id, the messages will sort desc by _id      |
| _minId         | ObjectId           | false    | Read the messages after this id, the messages will sort asc by _id        |
| _besideId      | ObjectId           | false    | Read the messages beside this id, the messages will sort asc by _id, the result collection will be twice the length of limit |
| category       | String             | false    | Category of message attachments                                           |
| fileCategory   | String             | false    | Message file category (image, document, media, other)                     |
| _markId        | ObjectId           | false    | Mark id                                                                    |

## Request
```
GET /v2/messages?_roomId=549908a68cd040715c48cadf HTTP/1.1
```

## Response
```json
[
  {
    "_id": "549908a78cd040715c48caf2",
    "room": {
      "_id": "549908a68cd040715c48cadf",
      "email": "room1.r2e29c2a0@talk.ai",
      "team": "549908a68cd040715c48cad3",
      "topic": "room1",
      "pinyin": "room1",
      "creator": "549908a68cd040715c48cad1",
      "guestToken": "2e297480",
      "__v": 0,
      "updatedAt": "2014-12-23T06:16:06.856Z",
      "createdAt": "2014-12-23T06:16:06.856Z",
      "pinyins": [
        "room1"
      ],
      "color": "blue",
      "isArchived": false,
      "isGeneral": false,
      "guestUrl": "http://guest.talk.bi/rooms/2e297480",
      "_creatorId": "549908a68cd040715c48cad1",
      "_teamId": "549908a68cd040715c48cad3",
      "id": "549908a68cd040715c48cadf"
    },
    "creator": {
      "_id": "549908a68cd040715c48cad1",
      "name": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "avatarUrl": "null",
      "email": "user1@teambition.com",
      "__v": 0,
      "globalRole": "user",
      "isRobot": false,
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "updatedAt": "2014-12-23T06:16:06.719Z",
      "createdAt": "2014-12-23T06:16:06.719Z",
      "source": "teambition",
      "id": "549908a68cd040715c48cad1"
    },
    "body": "third",
    "__v": 0,
    "updatedAt": "2014-12-23T06:16:07.047Z",
    "createdAt": "2014-12-23T06:16:07.047Z",
    "_roomId": "549908a68cd040715c48cadf",
    "_creatorId": "549908a68cd040715c48cad1",
    "id": "549908a78cd040715c48caf2"
  },
  {
    "_id": "549908a78cd040715c48caf1",
    "room": {
      "_id": "549908a68cd040715c48cadf",
      "email": "room1.r2e29c2a0@talk.ai",
      "team": "549908a68cd040715c48cad3",
      "topic": "room1",
      "pinyin": "room1",
      "creator": "549908a68cd040715c48cad1",
      "guestToken": "2e297480",
      "__v": 0,
      "updatedAt": "2014-12-23T06:16:06.856Z",
      "createdAt": "2014-12-23T06:16:06.856Z",
      "pinyins": [
        "room1"
      ],
      "color": "blue",
      "isArchived": false,
      "isGeneral": false,
      "guestUrl": "http://guest.talk.bi/rooms/2e297480",
      "_creatorId": "549908a68cd040715c48cad1",
      "_teamId": "549908a68cd040715c48cad3",
      "id": "549908a68cd040715c48cadf"
    },
    "creator": {
      "_id": "549908a68cd040715c48cad1",
      "name": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "avatarUrl": "null",
      "email": "user1@teambition.com",
      "__v": 0,
      "globalRole": "user",
      "isRobot": false,
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "updatedAt": "2014-12-23T06:16:06.719Z",
      "createdAt": "2014-12-23T06:16:06.719Z",
      "source": "teambition",
      "id": "549908a68cd040715c48cad1"
    },
    "body": "second",
    "__v": 0,
    "updatedAt": "2014-12-23T06:16:07.027Z",
    "createdAt": "2014-12-23T06:16:07.027Z",
    "_roomId": "549908a68cd040715c48cadf",
    "_creatorId": "549908a68cd040715c48cad1",
    "id": "549908a78cd040715c48caf1"
  }
]
```
