## guest/user.create

### summary
Update guest user

### method
PUT

### route
> /api/users/547fd9cbef51d4a78369c1ae

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
      <td>name</td>
      <td>String</td>
      <td>false</td>
      <td>user name</td>
    </tr>
    <tr>
      <td>email</td>
      <td>String</td>
      <td>false</td>
      <td>email</td>
    </tr>
  </tbody>
</table>

### request
```
PUT /api/users/547fd9cbef51d4a78369c1ae HTTP/1.1
{
  "name": "newguest",
  "email": "newguest@a.com"
}
```

### response
```json
{
  "_id": "547fd9cbef51d4a78369c1ae",
  "name": "newguest",
  "pinyin": "newguest",
  "email": "newguest@a.com",
  "__v": 1,
  "globalRole": "guest",
  "isRobot": false,
  "pinyins": [
    "newguest"
  ],
  "from": "register",
  "updatedAt": "2014-12-04T03:49:31.887Z",
  "createdAt": "2014-12-04T03:49:31.738Z",
  "source": "talk",
  "id": "547fd9cbef51d4a78369c1ae"
}
```
