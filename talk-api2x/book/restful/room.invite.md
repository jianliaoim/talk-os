## room.invite

Invite user to room by email, mobile or _userId

### Route
> POST /v2/rooms/:_id/invite

### Events
* When user is existing [room:join](../event/room.join.html)
* When user is nonexistent [invitation:create](../event/invitation.create.html)

### Params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| email          | String             | false    | User's email address |
| mobile         | String             | false    | User's phone number |
| _userId        | String(ObjectId)   | false    | User's id |

### Request
```
POST /v2/rooms/539023a3822fb04c1c679469/invite HTTP/1.1
{
  email: 'dajiangyou@teambition.com'
}
```

### Response
```json
{
  "_id": "55f13faf8be34c3d6d4de90d",
  "name": "路人甲",
  "py": "lrj",
  "pinyin": "lurenjia",
  "emailForLogin": "lurenjia@teambition.com",
  "emailDomain": "teambition.com",
  "__v": 0,
  "updatedAt": "2015-09-10T08:30:39.657Z",
  "createdAt": "2015-09-10T08:30:39.657Z",
  "isGuest": false,
  "isRobot": false,
  "pys": [
    "lrj"
  ],
  "pinyins": [
    "lurenjia"
  ],
  "from": "register",
  "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/4.png",
  "room": {
    "_id": "55f13faf8be34c3d6d4de909",
    "email": "room1.r37b7a00071@talk.ai",
    "team": "55f13faf8be34c3d6d4de8da",
    "topic": "room1",
    "py": "room1",
    "pinyin": "room1",
    "creator": "55f13faf8be34c3d6d4de8d8",
    "guestToken": "37b72ad0",
    "__v": 0,
    "updatedAt": "2015-09-10T08:30:39.614Z",
    "createdAt": "2015-09-10T08:30:39.614Z",
    "memberCount": 3,
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
    "popRate": 9,
    "guestUrl": "http://guest.talk.bi/rooms/37b72ad0",
    "_creatorId": "55f13faf8be34c3d6d4de8d8",
    "_teamId": "55f13faf8be34c3d6d4de8da",
    "id": "55f13faf8be34c3d6d4de909"
  },
  "_roomId": "55f13faf8be34c3d6d4de909",
  "_teamId": "55f13faf8be34c3d6d4de8da",
  "role": "member",
  "id": "55f13faf8be34c3d6d4de90d"
}
```

> When the invitee is nonexistent in talk, you'll receive a `invitation` object instead of a `user` object, which have a `isInvite` property.

```json
{
  "__v": 0,
  "mobile": "13100000000",
  "team": "55f13faf8be34c3d6d4de8da",
  "room": {
    "_id": "55f13faf8be34c3d6d4de909",
    "email": "room1.r37b7a00071@talk.ai",
    "team": "55f13faf8be34c3d6d4de8da",
    "topic": "room1",
    "py": "room1",
    "pinyin": "room1",
    "creator": "55f13faf8be34c3d6d4de8d8",
    "guestToken": "37b72ad0",
    "__v": 0,
    "updatedAt": "2015-09-10T08:30:39.614Z",
    "createdAt": "2015-09-10T08:30:39.614Z",
    "memberCount": 3,
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
    "popRate": 9,
    "guestUrl": "http://guest.talk.bi/rooms/37b72ad0",
    "_creatorId": "55f13faf8be34c3d6d4de8d8",
    "_teamId": "55f13faf8be34c3d6d4de8da",
    "id": "55f13faf8be34c3d6d4de909"
  },
  "key": "mobile_13100000000",
  "name": "13100000000",
  "_id": "55f13faf8be34c3d6d4de912",
  "updatedAt": "2015-09-10T08:30:39.841Z",
  "createdAt": "2015-09-10T08:30:39.841Z",
  "isInvite": true,
  "role": "member",
  "_teamId": "55f13faf8be34c3d6d4de8da",
  "_roomId": "55f13faf8be34c3d6d4de909",
  "id": "55f13faf8be34c3d6d4de912"
}
```
