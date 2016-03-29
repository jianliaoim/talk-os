## team.leave

### summary
leave a team

### method
POST

### route
> /v2/teams/:_id/leave

### events
* [team:leave](../event/team.leave.html)

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
      <td>_id</td>
      <td>String(ObjectId|InUrl)</td>
      <td>true</td>
      <td>team id</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/teams/536c834d26faf71918b774ed/leave HTTP/1.1
```

### response
```
{
  "ok": 1
}
```
