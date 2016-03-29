## integration.read

### summary
read the integrations by teamId

### method
GET

### route
> /v2/integrations

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
      <td>_teamId</td>
      <td>String(ObjectId)</td>
      <td>true</td>
      <td>team id</td>
    </tr>
  </tbody>
</table>

### request
```
GET /v2/integrations?_teamId=536c9d223888f40b20b7e278 HTTP/1.1
```

### response
```json
[{
    "__v": 0,
    "creator": "538d7a8eb0064cd263ea24cd",
    "room": "538d7d6d255600da6286865b",
    "team": "536c9d223888f40b20b7e278",
    "createdAt": "2014-06-12T05:00:51.654Z",
    "updatedAt": "2014-06-12T05:00:51.654Z",
    "_id": "53993403c3bc0c47175f468a",
    "_teamId": "536c9d223888f40b20b7e278",
    "_roomId": "538d7d6d255600da6286865b",
    "_creatorId": "538d7a8eb0064cd263ea24cd",
    "category": "weibo",
    "notifications": {'abc': 1, 'efg': 1},
    "id": "53993403c3bc0c47175f468a"
}, {
    "__v": 0,
    "creator": "538d7a8eb0064cd263ea24cd",
    "room": "538d7d6d255600da6286865b",
    "team": "536c9d223888f40b20b7e278",
    "createdAt": "2014-06-12T05:00:51.654Z",
    "updatedAt": "2014-06-12T05:00:51.654Z",
    "_id": "53993403c3bc0c47175f468a",
    "_teamId": "536c9d223888f40b20b7e278",
    "_roomId": "538d7d6d255600da6286865b",
    "_creatorId": "538d7a8eb0064cd263ea24cd",
    "category": "weibo",
    "notifications": {'abc': 1, 'efg': 1},
    "id": "53993403c3bc0c47175f468a"
}]
```
