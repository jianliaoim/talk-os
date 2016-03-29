## favorite.remove

### summary
Remove a favorite

### method
DELETE

### route
> /v2/favorites/:_id

### events
* [favorite:delete](../event/favorite.delete.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |

### Request
```json
DELETE /v2/favorites/556443878c07421d65d53ed4 HTTP/1.1
```

### Response
```json
{
  "__v": 0,
  "content": [
    "hello"
  ],
  "team": "55652f6b1795854b72780c19",
  "room": {
    "_id": "55652f6b1795854b72780c2f",
    "email": "room1.r37a1a77024@talk.ai",
    "team": "55652f6b1795854b72780c19",
    "topic": "room1",
    "pinyin": "room1",
    "creator": "55652f6b1795854b72780c15",
    "guestToken": "37a15950",
    "__v": 0,
    "updatedAt": "2015-05-27T02:43:55.365Z",
    "createdAt": "2015-05-27T02:43:55.365Z",
    "memberCount": 1,
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
    "guestUrl": "http://guest.talk.bi/rooms/37a15950",
    "_creatorId": "55652f6b1795854b72780c15",
    "_teamId": "55652f6b1795854b72780c19",
    "id": "55652f6b1795854b72780c2f"
  },
  "creator": {
    "_id": "55652f6b1795854b72780c15",
    "name": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "email": "user1@teambition.com",
    "emailDomain": "teambition.com",
    "__v": 0,
    "globalRole": "user",
    "hasPwd": false,
    "isActived": false,
    "isRobot": false,
    "pinyins": [
      "dajiangyou1"
    ],
    "from": "register",
    "updatedAt": "2015-05-27T02:43:55.096Z",
    "createdAt": "2015-05-27T02:43:55.095Z",
    "avatarUrl": "null",
    "id": "55652f6b1795854b72780c15"
  },
  "favoritedBy": "55652f6b1795854b72780c15",
  "message": "55652f6b1795854b72780c37",
  "favoritedAt": "2015-05-27T02:43:55.505Z",
  "_id": "55652f6b1795854b72780c38",
  "updatedAt": "2015-05-27T02:43:55.411Z",
  "createdAt": "2015-05-27T02:43:55.411Z",
  "icon": "normal",
  "isMailable": true,
  "isPushable": true,
  "isSearchable": true,
  "isEditable": true,
  "isManual": true,
  "isStarred": false,
  "attachments": [],
  "_messageId": "55652f6b1795854b72780c37",
  "_favoritedById": "55652f6b1795854b72780c15",
  "displayMode": "message",
  "_teamId": "55652f6b1795854b72780c19",
  "_roomId": "55652f6b1795854b72780c2f",
  "_creatorId": "55652f6b1795854b72780c15",
  "id": "55652f6b1795854b72780c38"
}
```
