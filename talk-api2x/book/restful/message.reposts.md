## message.reposts

### Summary
repost a group of messages, to room or direct to a member of team.

### Method
POST

### Route
> /v2/messages/reposts

### Events
* [message:create](../event/message.create.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| _messageIds    | Array              | true     | Message ids                                                               |
| _roomId        | ObjectId           | false    | room id                                                                   |
| _teamId        | ObjectId           | false    | team id                                                                   |
| _toId          | ObjectId           | false    | target user id                                                            |

### Request
```json
POST /v2/messages/reposts HTTP/1.1
{
  "_messageIds": ["53915a822731262e14d806d5"],
  "_roomId":"53915a822731262e14d806d6"
}
```

### Response
```json
[{
  "__v": 0,
  "creator": {
    "_id": "55befdde3ccafa9f00de6c89",
    "name": "dajiangyou2",
    "py": "dajiangyou2",
    "pinyin": "dajiangyou2",
    "email": "user2@teambition.com",
    "emailDomain": "teambition.com",
    "mobile": "13388888888",
    "__v": 0,
    "globalRole": "user",
    "hasPwd": false,
    "isActived": false,
    "isRobot": false,
    "pys": [
      "dajiangyou2"
    ],
    "pinyins": [
      "dajiangyou2"
    ],
    "from": "register",
    "updatedAt": "2015-08-03T05:36:30.831Z",
    "createdAt": "2015-08-03T05:36:30.831Z",
    "avatarUrl": "null",
    "id": "55befdde3ccafa9f00de6c89"
  },
  "room": {
    "_id": "55befddf3ccafa9f00de6cb7",
    "email": "room2.r98464c901w@talk.ai",
    "team": "55befdde3ccafa9f00de6c8c",
    "topic": "room2",
    "py": "room2",
    "pinyin": "room2",
    "creator": "55befdde3ccafa9f00de6c88",
    "guestToken": "9845fe70",
    "__v": 0,
    "updatedAt": "2015-08-03T05:36:31.191Z",
    "createdAt": "2015-08-03T05:36:31.191Z",
    "memberCount": 1,
    "pys": [
      "room2"
    ],
    "pinyins": [
      "room2"
    ],
    "isGuestVisible": false,
    "color": "blue",
    "isPrivate": false,
    "isArchived": false,
    "isGeneral": false,
    "popRate": 3,
    "guestUrl": "http://guest.talk.bi/rooms/9845fe70",
    "_creatorId": "55befdde3ccafa9f00de6c88",
    "_teamId": "55befdde3ccafa9f00de6c8c",
    "id": "55befddf3ccafa9f00de6cb7"
  },
  "team": "55befdde3ccafa9f00de6c8b",
  "content": [
    "hello"
  ],
  "tags": [],
  "_id": "55befddf3ccafa9f00de6cbf",
  "updatedAt": "2015-08-03T05:36:31.394Z",
  "createdAt": "2015-08-03T05:36:31.394Z",
  "icon": "normal",
  "isMailable": true,
  "isPushable": true,
  "isSearchable": true,
  "isEditable": true,
  "isManual": true,
  "isStarred": false,
  "attachments": [],
  "displayMode": "message",
  "_teamId": "55befdde3ccafa9f00de6c8b",
  "_roomId": "55befddf3ccafa9f00de6cb7",
  "_creatorId": "55befdde3ccafa9f00de6c89",
  "id": "55befddf3ccafa9f00de6cbf"
}]
```
