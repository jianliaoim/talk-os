# message.receipt

Receipt a message

## Route
> POST /v2/messages/:_id/receipt

## Events
* [message:update](../event/message.update.html)

## params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |

## Request
```json
POST /v2/messages/53915a822731262e14d806d5/receipt HTTP/1.1
```

## Response
```json
{
  "_id": "56b034c617af4a47561cbf1f",
  "creator": {
    "_id": "56b034c517af4a47561cbf0a",
    "name": "dajiangyou1",
    "py": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "emailForLogin": "user1@teambition.com",
    "emailDomain": "teambition.com",
    "__v": 0,
    "unions": [],
    "updatedAt": "2016-02-02T04:47:01.398Z",
    "createdAt": "2016-02-02T04:47:01.397Z",
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
    "id": "56b034c517af4a47561cbf0a",
    "email": "user1@teambition.com"
  },
  "room": {
    "_id": "56b034c617af4a47561cbf1a",
    "email": "room1.r005c9f405d@mail.jianliao.com",
    "team": "56b034c617af4a47561cbf0c",
    "topic": "room1",
    "py": "room1",
    "pinyin": "room1",
    "creator": "56b034c517af4a47561cbf0a",
    "guestToken": "005bdbf0",
    "__v": 0,
    "updatedAt": "2016-02-02T04:47:02.448Z",
    "createdAt": "2016-02-02T04:47:02.448Z",
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
    "guestUrl": "http://guest.talk.bi/rooms/005bdbf0",
    "_creatorId": "56b034c517af4a47561cbf0a",
    "_teamId": "56b034c617af4a47561cbf0c",
    "id": "56b034c617af4a47561cbf1a"
  },
  "team": "56b034c617af4a47561cbf0c",
  "body": "to be",
  "__v": 0,
  "receiptors": [
    "56b034c517af4a47561cbf0b"
  ],
  "hasTag": false,
  "tags": [],
  "urls": [],
  "updatedAt": "2016-02-02T04:47:02.590Z",
  "createdAt": "2016-02-02T04:47:02.493Z",
  "displayType": "text",
  "icon": "normal",
  "isSystem": false,
  "attachments": [],
  "mentions": [],
  "type": "room",
  "_targetId": "56b034c617af4a47561cbf1a",
  "_teamId": "56b034c617af4a47561cbf0c",
  "_roomId": "56b034c617af4a47561cbf1a",
  "_creatorId": "56b034c517af4a47561cbf0a",
  "id": "56b034c617af4a47561cbf1f"
}
```
