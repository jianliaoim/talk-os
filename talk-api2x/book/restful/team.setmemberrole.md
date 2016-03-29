## team.setMemberRole

### summary
set the role of member

### method
POST

### route
> /v2/teams/:_id/setmemberrole

### events
* [member:update](../event/member.update.html)

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
    <tr>
      <td>_userId</td>
      <td>String(ObjectId)</td>
      <td>true</td>
      <td>target user id</td>
    </tr>
    <tr>
      <td>role</td>
      <td>String</td>
      <td>true</td>
      <td>role</td>
    </tr>
  </tbody>
</table>

### request
```
POST /v2/teams/536c834d26faf71918b774ed/setmemberrole HTTP/1.1
{
  "_userId": "536c834d26faf71918b774ea",
  "role": "admin"
}
```

### response
```
{
  "ok": 1
}
```
