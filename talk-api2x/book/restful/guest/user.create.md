## guest/user.create

### summary
Create guest user

### method
POST

### route
> /api/users

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
      <td>true</td>
      <td>user name</td>
    </tr>
    <tr>
      <td>email</td>
      <td>String</td>
      <td>false</td>
      <td>email</td>
    </tr>
    <tr>
      <td>avatarUrl</td>
      <td>String</td>
      <td>false</td>
      <td>avatar</td>
    </tr>
  </tbody>
</table>

### request
```
POST /api/users HTTP/1.1
{
  "name": "dajiangyou",
  "email": "dajiangyou@teambition.com"
}
```

### response
```json
{
  "__v": 0,
  "name": "dajiangyou",
  "pinyin": "dajiangyou",
  "email": "dajiangyou@teambition.com",
  "_id": "547ee05bdba045bc72de3c7a",
  "globalRole": "guest",
  "isRobot": false,
  "pinyins": [
    "dajiangyou"
  ],
  "from": "register",
  "updatedAt": "2014-12-03T10:05:15.687Z",
  "createdAt": "2014-12-03T10:05:15.687Z",
  "source": "teambition",
  "id": "547ee05bdba045bc72de3c7a"
}
```
