## user.landing

### summary
signin user with token

### method
GET

### route
> /v2/users/landing

### events
* [team:join](../event/team.join.html)  # only when the user is login with inviteCode

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
      <td>token</td>
    </tr>
    <tr>
      <td>nextUrl</td>
      <td>string</td>
      <td>false</td>
      <td>redirect to this url</td>
    </tr>
  </tbody>
</table>

### request
```
GET /v2/users/landing?token=e616b6ceba274cde14e6141f034a60f7142338aa6f8a209c2d896cd4a430661c8901179119038d1c261aa514d6ace23f HTTP/1.1
```

### response
```
GET / 301 Redirect
```
