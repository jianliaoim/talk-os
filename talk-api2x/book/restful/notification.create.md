# notification.create

Create a notification

## Route
> POST /v2/notifications

## Events
* [notification:update](../event/notification.update.html)

## Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| text           | String             | false    | Text of the notification    |
| isPinned       | Boolean            | false    | Flag of is pinned    |
| unreadNum      | Number             | false    | Unread message number    |
| isMute         | Boolean            | false    | Mute state of a notification, default: false |
| isHidden       | Boolean            | false    | Hidden state of a notification, default: false |
| _latestReadMessageId   | ObjectId            | false    | Latest read message id |

## Request
```
POST /v2/notifications HTTP/1.1
{
   "isPinned": true,
   "_targetId": "56172b14475cd355953d43ea",
   "_teamId": "56172b14475cd355953d43eb",
   "type": "story"
}
```

## Response
```json
{
  "_id": "567cbff0458d3ac000d656ff",
  "_latestReadMessageId": "567cbff0458d3ac000d656fd",
  "type": "dms",
  "target": {
    "_id": "567cbff0458d3ac000d656c9",
    "name": "dajiangyou2",
    "py": "dajiangyou2",
    "pinyin": "dajiangyou2",
    "emailForLogin": "user2@teambition.com",
    "emailDomain": "teambition.com",
    "__v": 0,
    "unions": [],
    "updatedAt": "2015-12-25T04:02:56.421Z",
    "createdAt": "2015-12-25T04:02:56.421Z",
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
    "id": "567cbff0458d3ac000d656c9",
    "email": "user2@teambition.com"
  },
  "user": "567cbff0458d3ac000d656c8",
  "_emitterId": "567cbff0458d3ac000d656fd",
  "creator": {
    "_id": "567cbff0458d3ac000d656c8",
    "name": "dajiangyou1",
    "py": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "emailForLogin": "user1@teambition.com",
    "emailDomain": "teambition.com",
    "__v": 0,
    "unions": [],
    "updatedAt": "2015-12-25T04:02:56.413Z",
    "createdAt": "2015-12-25T04:02:56.412Z",
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
    "id": "567cbff0458d3ac000d656c8",
    "email": "user1@teambition.com"
  },
  "team": "567cbff0458d3ac000d656ee",
  "__v": 0,
  "updatedAt": "2015-12-25T04:02:57.050Z",
  "createdAt": "2015-12-25T04:02:56.806Z",
  "isHidden": false,
  "isMute": false,
  "isPinned": false,
  "unreadNum": 0,
  "text": "Hello",
  "_creatorId": "567cbff0458d3ac000d656c8",
  "_targetId": "567cbff0458d3ac000d656c9",
  "_teamId": "567cbff0458d3ac000d656ee",
  "_userId": "567cbff0458d3ac000d656c8",
  "id": "567cbff0458d3ac000d656ff"
}
```
