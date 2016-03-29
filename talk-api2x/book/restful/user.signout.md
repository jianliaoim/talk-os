## user.signout

### summary
Sign out

### method
POST

### route
> /v2/users/signout

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
      <td>X-Client-Type</td>
      <td>String(Header)</td>
      <td>false</td>
      <td>device type</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/users/signout HTTP/1.1
```

### response
```
{
  "ok": 1
}
```
