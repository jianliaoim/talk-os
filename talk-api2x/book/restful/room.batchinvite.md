## room.batchInvite

Invite user to room by emails, mobiles or _userIds

### Route
> POST /v2/rooms/:_id/batchinvite

### events
* When user is existing [room:join](../event/room.join.html)
* When user is nonexistent [invitation:create](../event/invitation.create.html)

### Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| emails          | Array(String)     | false    | User's email address |
| mobiles         | Array(ObjectId)   | false    | User's phone number |
| _userIds        | Array(ObjectId)   | false    | User's id |

### Request
```
POST /v2/rooms/539023a3822fb04c1c679469/batchinvite HTTP/1.1
{
  emails: ['dajiangyou@roombition.com', 'lurenjia@roombition.com']
}
```

### Response
```json
[
  {
    "__v": 0,
    "email": "lurenjia@teambition.com",
    "team": "55f13faf8be34c3d6d4de915",
    "room": {
      "_id": "55f13faf8be34c3d6d4de921",
      "email": "room1.r37ec92b02w@talk.ai",
      "team": "55f13faf8be34c3d6d4de915",
      "topic": "room1",
      "py": "room1",
      "pinyin": "room1",
      "creator": "55f13faf8be34c3d6d4de913",
      "guestToken": "37ec1d80",
      "__v": 0,
      "updatedAt": "2015-09-10T08:30:39.961Z",
      "createdAt": "2015-09-10T08:30:39.961Z",
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
      "popRate": 3,
      "guestUrl": "http://guest.talk.bi/rooms/37ec1d80",
      "_creatorId": "55f13faf8be34c3d6d4de913",
      "_teamId": "55f13faf8be34c3d6d4de915",
      "id": "55f13faf8be34c3d6d4de921"
    },
    "key": "email_lurenjia@teambition.com",
    "name": "lurenjia",
    "_id": "55f13fb08be34c3d6d4de925",
    "updatedAt": "2015-09-10T08:30:40.030Z",
    "createdAt": "2015-09-10T08:30:40.030Z",
    "isInvite": true,
    "role": "member",
    "_teamId": "55f13faf8be34c3d6d4de915",
    "_roomId": "55f13faf8be34c3d6d4de921",
    "id": "55f13fb08be34c3d6d4de925"
  },
  {
    "__v": 0,
    "mobile": "13111111111",
    "team": "55f13faf8be34c3d6d4de915",
    "room": {
      "_id": "55f13faf8be34c3d6d4de921",
      "email": "room1.r37ec92b02w@talk.ai",
      "team": "55f13faf8be34c3d6d4de915",
      "topic": "room1",
      "py": "room1",
      "pinyin": "room1",
      "creator": "55f13faf8be34c3d6d4de913",
      "guestToken": "37ec1d80",
      "__v": 0,
      "updatedAt": "2015-09-10T08:30:39.961Z",
      "createdAt": "2015-09-10T08:30:39.961Z",
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
      "popRate": 3,
      "guestUrl": "http://guest.talk.bi/rooms/37ec1d80",
      "_creatorId": "55f13faf8be34c3d6d4de913",
      "_teamId": "55f13faf8be34c3d6d4de915",
      "id": "55f13faf8be34c3d6d4de921"
    },
    "key": "mobile_13111111111",
    "name": "13111111111",
    "_id": "55f13fb08be34c3d6d4de926",
    "updatedAt": "2015-09-10T08:30:40.032Z",
    "createdAt": "2015-09-10T08:30:40.032Z",
    "isInvite": true,
    "role": "member",
    "_teamId": "55f13faf8be34c3d6d4de915",
    "_roomId": "55f13faf8be34c3d6d4de921",
    "id": "55f13fb08be34c3d6d4de926"
  }
]
```
