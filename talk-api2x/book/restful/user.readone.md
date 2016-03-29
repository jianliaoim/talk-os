## user.readOne

### summary
Get user info

### method
GET

### route
> /v2/users/:_id

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |

### request
```
GET /v2/users/me HTTP/1.1
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
