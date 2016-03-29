# room.remove

Remove room

## Route

> DELETE /v2/rooms/:_id

## Events

* [room:remove](../event/room.remove.html)
* [notification:remove](../event/notification.remove.html)

## Params
| key            | type               | required | description                                                  |
| -------------- | ------------------ | -------- | ------------------------------------------------------------ |

## Request
```json
DELETE /v2/rooms/536c9d223888f40b20b7e278 HTTP/1.1
Content-Type: application/json
```

## Response
```json
{
  "_id": "55029f72aaa3671e6b6cfffc",
  "email": "room1.rca28ab20@talk.ai",
  "team": "55029f72aaa3671e6b6cfff0",
  "topic": "room1",
  "pinyin": "room1",
  "creator": "55029f72aaa3671e6b6cffee",
  "guestToken": "ca2835f0",
  "__v": 0,
  "updatedAt": "2015-03-13T08:27:30.383Z",
  "createdAt": "2015-03-13T08:27:30.383Z",
  "memberCount": 1,
  "pinyins": [
    "room1"
  ],
  "isGuestVisible": false,
  "color": "blue",
  "isPrivate": false,
  "isArchived": false,
  "isGeneral": false,
  "popRate": 3,
  "guestUrl": "http://guest.talk.bi/rooms/ca2835f0",
  "_creatorId": "55029f72aaa3671e6b6cffee",
  "_teamId": "55029f72aaa3671e6b6cfff0",
  "id": "55029f72aaa3671e6b6cfffc"
}
```
