## integration.update

### summary
update the integration's token, room or notifications

### method
PUT

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
    <tr>
      <td>token</td>
      <td>String</td>
      <td>false</td>
      <td>account token</td>
    </tr>
    <tr>
      <td>_roomId</td>
      <td>String(ObjectId)</td>
      <td>false</td>
      <td>room id</td>
    </tr>
    <tr>
      <td>notifications</td>
      <td>Object</td>
      <td>false</td>
      <td>subscribe notifications</td>
    </tr>
  </tbody>
</table>

### request
```
PUT /v2/integrations/53993403c3bc0c47175f468a HTTP/1.1
{
  notifications: {"afd": 1},
  _roomId: "538d7a8eb0064cd263ea24cd",
  token: "fasf-fasdfa-s2731262e14d806d5"
}
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
    "showname": "teambition开发者",
    "notifications": {"afd": 1},
    "id": "53993403c3bc0c47175f468a"
}
```
