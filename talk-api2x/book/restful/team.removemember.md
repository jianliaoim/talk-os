## team.removeMember

### summary
remove member from a team

### method
POST

### route
> /v2/teams/:_id/removemember

### events
* [team:leave](../event/team.leave.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| _userId        | String(ObjectId)   | true     | The removed user id                                                       |

### request
```
POST /v2/teams/536c834d26faf71918b774ed/removemember HTTP/1.1
{
  "_userId": "536c834d26faf71918b774ea"
}
```

### response
```json
{
  "ok": 1
}
```
