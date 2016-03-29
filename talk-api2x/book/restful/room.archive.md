## room.archive

### summary
archive room

### method
POST

### route
> /v2/rooms/:_id/archive

### events
* [room:archive](../event/room.archive.html)

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
  <tbody>
    <tr>
      <td>isArchived</td>
      <td>Boolean</td>
      <td>true</td>
      <td>archive state of room</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/rooms/536c9d223888f40b20b7e278/archive HTTP/1.1
Content-Type: application/json
{
  "isArchived": true
}
```

### response
```json
{
    "__v": 0,
    "topic": "New Topic",
    "creator": "536c834d26faf71918b774ea",
    "team": "536c99d0460682621f7ea6e5",
    "_id": "536c9d223888f40b20b7e278",
    "updatedAt": "2014-05-09T09:17:22.959Z",
    "createdAt": "2014-05-09T09:17:22.959Z",
    "_creatorId": "536c834d26faf71918b774ea",
    "_teamId": "536c99d0460682621f7ea6e5",
    "id": "536c9d223888f40b20b7e278",
    "isArchived": true,
    "prefs": {
      "isMute": false
    }
}
```
