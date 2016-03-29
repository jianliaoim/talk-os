## user.read

### summary
Get user list

### method
GET

### route
> /v2/users

### params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ---------------- |
| q              | String             | false    | Query string (email or mobile number) |
| emails         | String             | false    | Email filters (Should less than 500, split by commas)|
| mobiles        | String             | false    | Mobile filters (Should less than 500, split by commas)|

### request
```
GET /v2/users?mobiles=13700000001,13700000002 HTTP/1.1
```

### response
```json
[{
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
}]
```
