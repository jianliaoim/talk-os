## room.guest

### summary
refresh room.guestUrl

### method
POST

### route
> /v2/rooms/:_id/guest

### events
* [room:update](../event/room.update.html)

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
      <td>isGuestEnabled</td>
      <td>Boolean</td>
      <td>true</td>
      <td>whether guest enabled or not</td>
    </tr>
  </tbody>
</table>

### request
```
PUT /v2/rooms/536c9d223888f40b20b7e278/guest HTTP/1.1
Content-Type: application/json
{
  "isGuestEnabled": true
}
```

### response
```
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
    "guestUrl": "http://talk.ai/guest/fasdfasdfa",
    "guestToken": "fasdfasdfa"
    "isArchived": true
}
```
