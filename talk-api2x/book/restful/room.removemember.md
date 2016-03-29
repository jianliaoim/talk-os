## room.removeMember

### summary
Remove member from a private room

**Public room and general room can not remove members!**

### method
POST

### route
> /v2/rooms/:_id/removemember

### events
* [room:leave](../event/room.leave.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| _userId        | String(ObjectId)   | true     | The removed user id                                                       |

### request
```
POST /v2/rooms/536c834d26faf71918b774ed/removemember HTTP/1.1
{
  "_userId": "536c834d26faf71918b774ea"
}
```

### response
```json
{
  "_id": "551b6573c44a5d1c2f6df985",
  "email": "room1.reb7db4a0@talk.ai",
  "team": "551b6573c44a5d1c2f6df979",
  "topic": "room1",
  "pinyin": "room1",
  "creator": "551b6573c44a5d1c2f6df977",
  "guestToken": "eb7d3f70",
  "__v": 0,
  "updatedAt": "2015-04-01T03:26:43.943Z",
  "createdAt": "2015-04-01T03:26:43.943Z",
  "memberCount": 0,
  "pinyins": [
    "room1"
  ],
  "isGuestVisible": false,
  "color": "blue",
  "isPrivate": true,
  "isArchived": false,
  "isGeneral": false,
  "isNew": false,
  "popRate": 0,
  "guestUrl": "http://guest.talk.bi/rooms/eb7d3f70",
  "_creatorId": "551b6573c44a5d1c2f6df977",
  "_teamId": "551b6573c44a5d1c2f6df979",
  "id": "551b6573c44a5d1c2f6df985"
}
```
