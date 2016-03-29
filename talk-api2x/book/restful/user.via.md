## user.via

### summary
login with inviteCode

### method
GET

### route
> /v2/via/:inviteCode

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
      <td>inviteCode</td>
      <td>String(InUrl)</td>
      <td>true</td>
      <td>invite code</td>
    </tr>
  </tbody>
</table>

### request
```
GET /v2/via/87c11f309aa5 HTTP/1.1
```

### response
```
https://account.teambition.com/login 301 Redirect
```
