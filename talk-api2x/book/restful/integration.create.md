## integration.create

### summary
create integration

### method
POST

### route
> /v2/integrations

### events
* [integration:create](../event/integration.create.html)

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
      <td>_teamId</td>
      <td>String(ObjectId)</td>
      <td>true</td>
      <td>team id</td>
    </tr>
    <tr>
      <td>_roomId</td>
      <td>String(ObjectId)</td>
      <td>true</td>
      <td>room id</td>
    </tr>
    <tr>
      <td>category</td>
      <td>String</td>
      <td>true</td>
      <td>category of integration</td>
    </tr>
    <tr>
      <td>token</td>
      <td>String</td>
      <td>false</td>
      <td>account token of integration</td>
    </tr>
    <tr>
      <td>repos</td>
      <td>Array</td>
      <td>false</td>
      <td>repos of github</td>
    </tr>
    <tr>
      <td>notifications</td>
      <td>Object</td>
      <td>false</td>
      <td>subscribe notifications</td>
    </tr>
    <tr>
      <td>url</td>
      <td>String</td>
      <td>false</td>
      <td>rss url</td>
    </tr>
    <tr>
      <td>title</td>
      <td>String</td>
      <td>false</td>
      <td>title</td>
    </tr>
    <tr>
      <td>description</td>
      <td>String</td>
      <td>false</td>
      <td>description</td>
    </tr>
    <tr>
      <td>iconUrl</td>
      <td>String</td>
      <td>false</td>
      <td>icon of integration</td>
    </tr>
  </tbody>
</table>

### typeof integrations

- weibo: token, notifications
- rss: url
- github: token, notifications, repos
- coding: notifications
- jinshuju: notifications
- jiankongbao: notifications
- incoming: title, description, iconUrl

### request
```
POST /v2/integrations HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "category": "weibo",
  "token": "fasf-fasdfa-s2731262e14d806d5"
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
    "notifications": {"abc": 1, "efg": 1},
    "id": "53993403c3bc0c47175f468a"
}
```
