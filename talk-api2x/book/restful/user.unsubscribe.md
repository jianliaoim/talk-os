## user.unsubscribe

### summary
unsubscribe the user channel

### method
POST

### route
> /v2/users/unsubscribe

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
      <td>X-Socket-Id</td>
      <td>String(InHeader)</td>
      <td>true</td>
      <td>sockjs id</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/users/unsubscribe HTTP/1.1
X-Socket-Id: e9704a20-d751-11e3-8d0d-f55ce4b330df
```

### response
```
{
    "ok": 1
}
```
