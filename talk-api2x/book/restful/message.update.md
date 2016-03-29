## message.update

### summary
update message

### method
PUT

### route
> /v2/messages/:_id

### events
* [message:update](../event/message.update.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| content        | String/Array       | false    | Message content                                                           |
| text           | String             | false    | Rich text content                                                         |
| file           | Object             | false    | File object                                                               |
| _tagIds        | ObjectId           | false    | Tag ids                                                                   |

### request
```json
PUT /v2/messages/55a359c1f831a4172e391e18 HTTP/1.1
{
  "content": "hello world",
  "_tagIds" ["55a359c2f831a4172e391e19"]
}
```

### response
```json
{
  "_id": "55a359c1f831a4172e391e18",
  "creator": {
    "_id": "55a359c0f831a4172e391de5",
    "name": "dajiangyou1",
    "py": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "email": "user1@teambition.com",
    "emailDomain": "teambition.com",
    "mobile": "13388888888",
    "__v": 0,
    "globalRole": "user",
    "hasPwd": false,
    "isActived": false,
    "isRobot": false,
    "pys": [
      "dajiangyou1"
    ],
    "pinyins": [
      "dajiangyou1"
    ],
    "from": "register",
    "updatedAt": "2015-07-13T06:25:04.763Z",
    "createdAt": "2015-07-13T06:25:04.762Z",
    "avatarUrl": "null",
    "id": "55a359c0f831a4172e391de5"
  },
  "room": {
    "_id": "55a359c1f831a4172e391e10",
    "email": "room1.re6ce6ee02b@talk.ai",
    "team": "55a359c1f831a4172e391de8",
    "topic": "room1",
    "py": "room1",
    "pinyin": "room1",
    "creator": "55a359c0f831a4172e391de5",
    "guestToken": "e6cdd2a0",
    "__v": 0,
    "updatedAt": "2015-07-13T06:25:05.739Z",
    "createdAt": "2015-07-13T06:25:05.739Z",
    "memberCount": 1,
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
    "isNew": false,
    "popRate": 3,
    "guestUrl": "http://guest.talk.bi/rooms/e6cdd2a0",
    "_creatorId": "55a359c0f831a4172e391de5",
    "_teamId": "55a359c1f831a4172e391de8",
    "id": "55a359c1f831a4172e391e10",
    "prefs": {
      "isMute": false,
      "hideMobile": false
    }
  },
  "team": "55a359c1f831a4172e391de8",
  "content": [
    "hello"
  ],
  "__v": 1,
  "tags": [
    {
      "_id": "55a359c2f831a4172e391e19",
      "creator": "55a359c0f831a4172e391de5",
      "name": "测试",
      "team": "55a359c1f831a4172e391de8",
      "__v": 0,
      "updatedAt": "2015-07-13T06:25:06.108Z",
      "createdAt": "2015-07-13T06:25:06.108Z",
      "_creatorId": "55a359c0f831a4172e391de5",
      "_teamId": "55a359c1f831a4172e391de8",
      "id": "55a359c2f831a4172e391e19"
    }
  ],
  "updatedAt": "2015-07-13T06:25:06.149Z",
  "createdAt": "2015-07-13T06:25:05.890Z",
  "icon": "normal",
  "isMailable": true,
  "isPushable": true,
  "isSearchable": true,
  "isEditable": true,
  "isManual": true,
  "isStarred": false,
  "attachments": [],
  "displayMode": "message",
  "_teamId": "55a359c1f831a4172e391de8",
  "_roomId": "55a359c1f831a4172e391e10",
  "_creatorId": "55a359c0f831a4172e391de5",
  "id": "55a359c1f831a4172e391e18"
}
```
