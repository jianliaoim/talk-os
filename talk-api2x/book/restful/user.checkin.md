## user.checkin

### summary
Initialize user infomation

### method
POST

### route
> /v2/users/checkin

### events
* [team:join](../event/team.join.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| inviteCode     | String             | false    | Team invite code |

### request
```
POST /v2/users/checkin HTTP/1.1
{
  "inviteCode": "xxxxxxxxx"
}
```

### response
```json
{
    "name": "许晶鑫",
    "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/9.png",
    "email": "jingxin@teambition.com",
    "_id": "536c834d26faf71918b774ea",
    "mobile": "13700000001",
    "__v": 0,
    "isRobot": false,
    "updatedAt": "2014-05-09T07:27:09.280Z",
    "createdAt": "2014-05-09T07:27:09.280Z",
    "id": "536c834d26faf71918b774ea",
    "pinyin": "xujingxin"
}
```
