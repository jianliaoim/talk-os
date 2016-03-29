## room.leave

### summary
leave a room

### method
POST

### route
> /v2/rooms/:_id/leave

### events
* [room:leave](../event/room.leave.html)

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
      <td>_id</td>
      <td>String(ObjectId|InUrl)</td>
      <td>true</td>
      <td>room id</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/rooms/536c9d223888f40b20b7e278/leave HTTP/1.1
```

### response
```json
{
  "_id": "5486ba42a03ea6c51a469d10",
  "email": "room1.rdf71e690@talk.ai",
  "team": "5486ba42a03ea6c51a469d04",
  "topic": "room1",
  "pinyin": "room1",
  "creator": "5486ba42a03ea6c51a469d02",
  "guestToken": "df71bf80",
  "__v": 0,
  "updatedAt": "2014-12-09T09:00:50.424Z",
  "createdAt": "2014-12-09T09:00:50.424Z",
  "pinyins": [
    "room1"
  ],
  "color": "blue",
  "isArchived": false,
  "isGeneral": false,
  "guestUrl": "http://guest.talk.bi/rooms/df71bf80",
  "_creatorId": "5486ba42a03ea6c51a469d02",
  "_teamId": "5486ba42a03ea6c51a469d04",
  "id": "5486ba42a03ea6c51a469d10"
}
```
