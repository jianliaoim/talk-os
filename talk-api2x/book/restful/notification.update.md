# notification.update

Update notification

## Route
> PUT /v2/notifications/:_id

## Events
* [notification:update](../event/notification.update.html)

## Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| isPinned       | Boolean            | false    | Flag of is pinned    |
| unreadNum      | Number             | false    | Unread message number    |
| isMute         | Boolean            | false    | Mute state of a notification, default: false |
| isHidden       | Boolean            | false    | Hidden state of a notification, default: false |
| _latestReadMessageId   | ObjectId            | false    | Latest read message id |

## Request
```
PUT /v2/notifications/56172b13475cd355953d43b4 HTTP/1.1
{
   "isPinned": true
}
```

## Response
```json
{
  "_id": "56172b14475cd355953d43ea",
  "event": "message:create",
  "type": "room",
  "creator": {
    "_id": "56172b13475cd355953d43b2",
    "name": "dajiangyou1",
    "py": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "emailForLogin": "user1@teambition.com",
    "emailDomain": "teambition.com",
    "phoneForLogin": "13388888881",
    "__v": 0,
    "unions": [],
    "updatedAt": "2015-10-09T02:48:51.321Z",
    "createdAt": "2015-10-09T02:48:51.320Z",
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
    "id": "56172b13475cd355953d43b2",
    "mobile": "13388888881",
    "email": "user1@teambition.com"
  },
  "target": {
    "_id": "56172b14475cd355953d43e1",
    "email": "room1.r464bda903c@mail.jianliao.com",
    "team": "56172b13475cd355953d43b4",
    "topic": "room1",
    "py": "room1",
    "pinyin": "room1",
    "creator": "56172b13475cd355953d43b2",
    "guestToken": "464b8c70",
    "__v": 0,
    "updatedAt": "2015-10-09T02:48:52.151Z",
    "createdAt": "2015-10-09T02:48:52.151Z",
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
    "guestUrl": "http://guest.talk.bi/rooms/464b8c70",
    "_creatorId": "56172b13475cd355953d43b2",
    "_teamId": "56172b13475cd355953d43b4",
    "id": "56172b14475cd355953d43e1"
  },
  "team": "56172b13475cd355953d43b4",
  "user": "56172b13475cd355953d43b3",
  "__v": 0,
  "updatedAt": "2015-10-09T02:48:52.223Z",
  "createdAt": "2015-10-09T02:48:52.246Z",
  "unreadNum": 1,
  "oldUnreadNum": 1,
  "text": "room message",
  "_creatorId": "56172b13475cd355953d43b2",
  "_targetId": "56172b14475cd355953d43e1",
  "_teamId": "56172b13475cd355953d43b4",
  "_userId": "56172b13475cd355953d43b3",
  "id": "56172b14475cd355953d43ea"
}
```
