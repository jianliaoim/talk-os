## user.me

### summary
Get my info

### method
GET

### route
> /v2/users/me

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| syncAccount    | Boolean            | false    | Sync account infomation from teambition                                   |

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
    "pinyin": "xujingxin",
    "subAccountSid": "998e2dd85ac711e58a2aac853d9d52fd",
    "preference": {
        "_id": "5397f47255cf5f554823b6c0",
        "user": "538d7a8eb0064cd263ea24cd",
        "emailNotification": false,
        "desktopNotification": true,
        "hasShownTips": true,
        "_latestTeamId": "538d7a8eb0064cd263ea24c8",
        "_latestRoomId": "538d7a8eb0064cd263ea24c9",
        "updatedAt": "2014-05-09T07:27:09.280Z",
        "createdAt": "2014-05-09T07:27:09.280Z",
    },
    "voip": {
      "_id": "55f69b0624e228b29c55b4f9",
      "user": "55c06104261b8c02584f2a64",
      "voipAccount": "89279300000008",
      "voipPwd": "zKT4u6U2",
      "subToken": "88c0540fb0b6f1f66dadd4b8e6e7f914",
      "subAccountSid": "998e2dd85ac711e58a2aac853d9d52fd",
      "__v": 0,
      "updatedAt": "2015-09-14T10:01:42.758Z",
      "createdAt": "2015-09-14T10:01:42.758Z",
      "_userId": "55c06104261b8c02584f2a64",
      "id": "55f69b0624e228b29c55b4f9"
    }
}
```
