# room.create

Create a room, the room should belong to a team

## Route
> POST /v2/rooms

## Events
* [room:create](../event/room.create.html)

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _teamId        | ObjectId           | true     | Team id        |
| topic          | String             | true     | Topic of room  |
| _memberIds     | ObjectId           | false    | Member ids of room  |
| purpose        | String             | false    | Purpose of room  |
| isPrivate      | Boolean            | false    | Visibility of room (default: false) |

## Request
```
POST /v2/rooms HTTP/1.1
Content-Type: application/json
{
  "_teamId": "536c99d0460682621f7ea6e5",
  "topic": "New Room"
}
```

## Response
```json
{
    "__v": 0,
    "topic": "New Room",
    "creator": "536c834d26faf71918b774ea",
    "team": "536c99d0460682621f7ea6e5",
    "_id": "536c9d223888f40b20b7e278",
    "updatedAt": "2014-05-09T09:17:22.959Z",
    "createdAt": "2014-05-09T09:17:22.959Z",
    "_creatorId": "536c834d26faf71918b774ea",
    "_teamId": "536c99d0460682621f7ea6e5",
    "id": "536c9d223888f40b20b7e278",
    "purpose": 'hi',
    "members": [
        {
            "name": "许晶鑫",
            "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/9.png",
            "_id": "536c834d26faf71918b774ea",
            "__v": 0,
            "isRobot": false,
            "updatedAt": "2014-05-09T07:27:09.280Z",
            "createdAt": "2014-05-09T07:27:09.280Z",
            "id": "536c834d26faf71918b774ea"
        }
    ]
}
```
