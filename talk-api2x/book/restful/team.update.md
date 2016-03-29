## team.update

### summary
update team infomation or the preference of team

### method
PUT

### route
> /v2/teams/:_id

### events
* [team:update](../event/team.update.html) - Emit this event when update the basic properties of team. e.g. name, color, nonJoinable
* [team.prefs:update](../event/team.prefs.update.html) - Emit this event when update the user preference of this team. e.g. isMute, alias
* [team.members.prefs:update](../event/team.members.prefs.update.html) - Emit this event when other users update their preference for this team, e.g. alias

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| name           | String             | false    | team name |
| logoUrl        | String             | false    | Team logo's url |
| description    | String             | false    | Team description |
| shortName      | String             | false    | Short name of team |
| color          | String             | false    | 'blue', 'yellow', 'grass', 'purple', 'red', 'orange', 'cyan' |
| prefs          | Object             | false    | alias, isMute, hideMobile |

### request
```
PUT /v2/teams/536c99d0460682621f7ea6e5 HTTP/1.1
Content-Type: application/json
{
  "name":"new team",
  "prefs": {
    "isMute": true,
    "alias": "大西瓜"
  }
}
```

### response
```json
{
  "shortName": "iamshort",
  "_id": "56652f5a343d1f0b37347681",
  "name": "new team",
  "creator": "56652f5a343d1f0b3734767f",
  "__v": 0,
  "updatedAt": "2015-12-07T07:03:54.911Z",
  "createdAt": "2015-12-07T07:03:54.773Z",
  "nonJoinable": false,
  "inviteCode": "adbd9c505z",
  "color": "tea",
  "shortUrl": "https://jianliao.com/t/iamshort",
  "hasUnread": false,
  "inviteUrl": "https://jianliao.com/page/invite/adbd9c505z",
  "_creatorId": "56652f5a343d1f0b3734767f",
  "id": "56652f5a343d1f0b37347681"
}
```
