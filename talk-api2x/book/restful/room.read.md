## room.read

### summary
read a list of room that the user joined.

### method
GET

### route
> /v2/rooms

### params
<table>
  <thead>
    <tr>
      <th>key</th>
      <th>type</th>
      <th>required</th>
      <th>description</th>
    </tr>
  </thead>
</table>

### request
```
GET /v2/rooms HTTP/1.1
```

### response
```json
[
  {
    "topic": "New Room",
    "creator": "536c834d26faf71918b774ea",
    "team": "536c99d0460682621f7ea6e5",
    "_id": "536c9d223888f40b20b7e278",
    "__v": 0,
    "updatedAt": "2014-05-09T09:17:22.959Z",
    "createdAt": "2014-05-09T09:17:22.959Z",
    "_creatorId": "536c834d26faf71918b774ea",
    "_teamId": "536c99d0460682621f7ea6e5",
    "id": "536c9d223888f40b20b7e278",
    "isQuit": false,
    "memberCount": 1,
    "popRate": 3
  }
]
```
