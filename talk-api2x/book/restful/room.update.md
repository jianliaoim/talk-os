# room.update

update room infomation or the preference of room

## Route
> PUT /v2/rooms/:_id

## Events
* [room:update](../event/room.update.html) - Emit this event when update the basic properties of room. e.g. topic, purpose, isPrivate, color, isGuestVisible

## Params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| topic          | String             | false    | the topic of room                                                         |
| purpose        | String             | false    | the purpose of room                                                       |
| isPrivate      | Boolean            | false    | private state of room                                                     |
| color          | String             | false    | 'blue', 'yellow', 'grass', 'purple', 'red', 'orange', 'cyan'              |
| isGuestVisible | Boolean            | false    | show the history message to guest                                         |
| addMembers     | Array(ObjectId)    | false    | Add member (ids) to story |
| removeMembers  | Array(ObjectId)    | false    | Remove member (ids) from story |

## Request
```
PUT /v2/rooms/536c9d223888f40b20b7e278 HTTP/1.1
Content-Type: application/json
{
  "topic": "New Topic",
  "purpose": "吃成一个大西瓜"
}
```

## Response
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
  "_memberIds": [
    "5513a5a94ff269411d71734a"
  ],
  "color": "blue",
  "isPrivate": false,
  "isArchived": false,
  "isGeneral": false,
  "popRate": 3,
  "guestUrl": "http://guest.talk.bi/rooms/7d2db6a0",
  "_creatorId": "5513a5a94ff269411d71733c",
  "_teamId": "5513a5a94ff269411d71733e",
  "id": "5513a5a94ff269411d71734a"
}
```
