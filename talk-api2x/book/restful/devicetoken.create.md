## devicetoken.create

### summary
create devicetoken

### method
POST

### route
> /v2/devicetokens

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
      <td>token</td>
      <td>String</td>
      <td>true</td>
      <td>device token</td>
    </tr>
    <tr>
      <td>X-Client-Type</td>
      <td>String(Header)</td>
      <td>true</td>
      <td>device type</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/devicetokens HTTP/1.1
headers:
  X-Client-Type: ios
{
  "token":"abc"
}
```

### response
```
{
    "user": "538d7d6d255600da6286865b",
    "_userId": "538d7d6d255600da6286865b",
    "createdAt": "2014-06-12T05:00:51.654Z",
    "updatedAt": "2014-06-12T05:00:51.654Z",
    "_id": "53993403c3bc0c47175f468a",
    "token": "abc",
    "type": 'ios',
    "id": "53993403c3bc0c47175f468a"
}
```
