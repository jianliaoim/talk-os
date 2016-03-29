## integration.fetchgithubrepos

### summary
get github repos by token

### method
GET

### route
> /v2/integrations/fetchgithubrepos

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
      <td>github token</td>
    </tr>
  </tbody>
</table>

### request
```
GET /v2/integrations/fetchgithubrepos?token=fasdfasdfasd HTTP/1.1
```

### response
```
[
  "user1/repos1",
  "team1/repos2"
]
```
