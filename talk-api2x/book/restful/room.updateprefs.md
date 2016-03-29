## room.updateprefs

### summary
update the preference of room

### method
PUT

### route
> /v2/rooms/:_id/prefs

### events
* [room.prefs:update](../event/room.prefs.update.html) - Emit this event when update the user preference of this room. e.g. isMute, alias
* [room.members.prefs:update](../event/room.members.prefs.update.html) - Emit this event when other users update their preference for this room, e.g. alias

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| prefs          | Object             | false    | alias, isMute, hideMobile                                                             |

### request
```
PUT /v2/rooms/536c9d223888f40b20b7e278/prefs HTTP/1.1
Content-Type: application/json
{
  "prefs": {
    "isMute": true,
    "alias": "大西瓜"
  }
}
```

### response

The room object

```json
{
  "_id": "5513a5a94ff269411d71734a",
  "email": "room1.r7d2e04c0@talk.ai",
  "team": "5513a5a94ff269411d71733e",
  "topic": "room1",
  "pinyin": "room1",
  "creator": "5513a5a94ff269411d71733c",
  "guestToken": "7d2db6a0",
  "__v": 0,
  "updatedAt": "2015-03-26T06:22:33.738Z",
  "createdAt": "2015-03-26T06:22:33.738Z",
  "memberCount": 1,
  "pinyins": [
    "room1"
  ],
  "isGuestVisible": false,
  "color": "blue",
  "isPrivate": false,
  "isArchived": false,
  "isGeneral": false,
  "prefs": {
    "isMute": true,
    "alias": "大西瓜"
  },
  "popRate": 3,
  "guestUrl": "http://guest.talk.bi/rooms/7d2db6a0",
  "_creatorId": "5513a5a94ff269411d71733c",
  "_teamId": "5513a5a94ff269411d71733e",
  "id": "5513a5a94ff269411d71734a"
}
```
