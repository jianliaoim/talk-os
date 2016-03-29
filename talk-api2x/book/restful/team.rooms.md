# team.rooms

Read room list of the team

## Route
> GET /v2/teams/:_id/rooms

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| isArchived     | Boolean            | false    | Archived state of room  |

## Request
```json
GET /v2/teams/536c834d26faf71918b774ed/rooms HTTP/1.1
```

## Response
```json
[
  {
    "_id": "5626fad3e16fef724c3ed0bd",
    "email": "room1.reb9397701q@mail.jianliao.com",
    "team": "5626fad3e16fef724c3ed090",
    "topic": "room1",
    "py": "room1",
    "pinyin": "room1",
    "creator": "5626fad2e16fef724c3ed08e",
    "guestToken": "eb932240",
    "__v": 0,
    "updatedAt": "2015-10-21T02:39:15.556Z",
    "createdAt": "2015-10-21T02:39:15.556Z",
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
    "_memberIds": [
      "5626fad2e16fef724c3ed08e",
      "5626fad2e16fef724c3ed08f"
    ],
    "isQuit": false,
    "unread": 0,
    "prefs": {
      "isMute": false,
      "hideMobile": false
    },
    "popRate": 6,
    "guestUrl": "http://guest.talk.bi/rooms/eb932240",
    "_creatorId": "5626fad2e16fef724c3ed08e",
    "_teamId": "5626fad3e16fef724c3ed090",
    "id": "5626fad3e16fef724c3ed0bd"
  },
  {
    "_id": "5626fad3e16fef724c3ed092",
    "email": "general.reb62ea801o@mail.jianliao.com",
    "team": "5626fad3e16fef724c3ed090",
    "topic": "general",
    "py": "general",
    "pinyin": "general",
    "creator": "5626fad2e16fef724c3ed08e",
    "__v": 0,
    "updatedAt": "2015-10-21T02:39:15.234Z",
    "createdAt": "2015-10-21T02:39:15.234Z",
    "memberCount": 2,
    "pys": [
      "general"
    ],
    "pinyins": [
      "general"
    ],
    "isGuestVisible": true,
    "color": "blue",
    "isPrivate": false,
    "isArchived": false,
    "isGeneral": true,
    "_memberIds": [
      "5626fad2e16fef724c3ed08e",
      "5626fad2e16fef724c3ed08f"
    ],
    "isQuit": false,
    "unread": 0,
    "prefs": {
      "isMute": false,
      "hideMobile": false
    },
    "popRate": 6,
    "_creatorId": "5626fad2e16fef724c3ed08e",
    "_teamId": "5626fad3e16fef724c3ed090",
    "id": "5626fad3e16fef724c3ed092"
  }
]
```
