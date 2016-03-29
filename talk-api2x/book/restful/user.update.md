## user.update

### summary
Update infomation of user

### method
PUT

### route
> /v2/users/:_id

### event
* [user:update](../event/user.update.html)

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
      <td>avatarUrl</td>
      <td>String</td>
      <td>false</td>
      <td>avatar url</td>
    </tr>
    <tr>
      <td>mobile</td>
      <td>String</td>
      <td>false</td>
      <td>mobile phone</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/users/536c834d26faf71918b774ea HTTP/1.1
{
  "name":"xjx",
  "avatarUrl":"someurl"
}
```

### response
```
{
    "name": "xjx",
    "avatarUrl": "someurl",
    "email": "jingxin@teambition.com",
    "_id": "536c834d26faf71918b774ea",
    "mobile": "13700000001",
    "__v": 0,
    "isRobot": false,
    "updatedAt": "2014-05-09T07:27:09.280Z",
    "createdAt": "2014-05-09T07:27:09.280Z",
    "id": "536c834d26faf71918b774ea"
}
```
