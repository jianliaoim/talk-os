## team.updateprefs

### summary
update the preference of team

### method
PUT

### route
> /v2/teams/:_id/prefs

### events
* [team.prefs:update](../event/team.prefs.update.html) - Emit this event when update the user preference of this team. e.g. isMute, alias
* [team.members.prefs:update](../event/team.members.prefs.update.html) - Emit this event when other users update their preference for this team, e.g. alias

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| prefs          | Object             | false    | alias, isMute, hideMobile                                                             |

### request
```
PUT /v2/teams/536c99d0460682621f7ea6e5/prefs HTTP/1.1
Content-Type: application/json
{
  "prefs": {
    "isMute": true,
    "alias": "大西瓜"
  }
}
```

### response

The team object

```json
{
    "__v": 0,
    "name": "new team",
    "creator": "536c834d26faf71918b774ea",
    "createdAt": "2014-05-09T09:03:12.838Z",
    "_id": "536c99d0460682621f7ea6e5",
    "updatedAt": "2014-05-09T09:03:12.838Z",
    "_creatorId": "536c834d26faf71918b774ea",
    "id": "536c99d0460682621f7ea6e5"
}
```
