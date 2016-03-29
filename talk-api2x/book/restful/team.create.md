# team.create

Create team

## Route

> POST /v2/teams

## Params
| key            | type               | required | description                                                  |
| -------------- | ------------------ | -------- | ------------------------------------------------------------ |
| name           | String             | true     | Team name |
| logoUrl        | String             | false    | Team logo's url |
| description    | String             | false    | Team description |

## Request
```json
POST /v2/teams HTTP/1.1
Content-Type: application/json
{
  "name":"new team"
}
```

## Response
```json
{
    "__v": 0,
    "name": "new team",
    "creator": "537c210205b9931f0afdb04c",
    "createdAt": "2014-05-23T03:26:38.168Z",
    "_id": "537ebfeedcd740ab091b2b89",
    "updatedAt": "2014-05-23T03:26:38.168Z",
    "_creatorId": "537c210205b9931f0afdb04c",
    "id": "537ebfeedcd740ab091b2b89",
    "members": [
        {
            "name": "许晶鑫",
            "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/9.png",
            "email": "jingxin@teambition.com",
            "_id": "537c210205b9931f0afdb04c",
            "__v": 0,
            "isRobot": false,
            "updatedAt": "2014-05-21T03:44:02.774Z",
            "createdAt": "2014-05-21T03:44:02.774Z",
            "id": "537c210205b9931f0afdb04c"
        }
    ],
    "rooms": [
        {
            "__v": 0,
            "team": "537ebfeedcd740ab091b2b89",
            "topic": "general",
            "_id": "537ebfeedcd740ab091b2b8b",
            "updatedAt": "2014-05-23T03:26:38.197Z",
            "createdAt": "2014-05-23T03:26:38.197Z",
            "isGeneral": true,
            "_teamId": "537ebfeedcd740ab091b2b89",
            "id": "537ebfeedcd740ab091b2b8b"
        }
    ]
}
```
