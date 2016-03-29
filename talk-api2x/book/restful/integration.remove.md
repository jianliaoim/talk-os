## integration.remove

### summary
delete the integration by id

### method
DELETE

### route
> /v2/integrations/53993403c3bc0c47175f468a

### events
* [integration:remove](../event/integration.remove.html)

### list of integrations
* [integrations](/doc/integrations/readme.html)

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
      <td>String(ObjectId|Inurl)</td>
      <td>true</td>
      <td>integration id</td>
    </tr>
  </tbody>
</table>

### request
```
DELETE /v2/integrations/53993403c3bc0c47175f468a HTTP/1.1
```

### response
```json
{
    "__v": 0,
    "creator": "538d7a8eb0064cd263ea24cd",
    "room": "538d7d6d255600da6286865b",
    "team": "538d7a8eb0064cd263ea24ca",
    "createdAt": "2014-06-12T05:00:51.654Z",
    "updatedAt": "2014-06-12T05:00:51.654Z",
    "_id": "53993403c3bc0c47175f468a",
    "_teamId": "538d7a8eb0064cd263ea24ca",
    "_roomId": "538d7d6d255600da6286865b",
    "_creatorId": "538d7a8eb0064cd263ea24cd",
    "category": "weibo",
    "id": "53993403c3bc0c47175f468a"
}
```
