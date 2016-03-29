## team.batchInvite

Invite user to team by emails, mobiles or _userIds

### Route
> POST /v2/teams/:_id/batchinvite

### Events

* When user is existing [team:join](../event/team.join.html)
* When user is nonexistent [invitation:create](../event/invitation.create.html)

### Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| emails          | Array(String)     | false    | User's email address |
| mobiles         | Array(ObjectId)   | false    | User's phone number |
| _userIds        | Array(ObjectId)   | false    | User's id |

### Request
```
POST /v2/teams/539023a3822fb04c1c679469/batchinvite HTTP/1.1
{
  emails: ['dajiangyou@teambition.com', 'lurenjia@teambition.com']
}
```

### Response
```json
[{
  "__v": 0,
  "sourceId": "53febfcb2c52a0b243c594bc",
  "email": "lurenjia@teambition.com",
  "name": "lurenjia",
  "pinyin": "lurenjia",
  "_id": "54c09be1c6174f9f605b277e",
  "globalRole": "user",
  "isRobot": false,
  "pinyins": [
    "lurenjia"
  ],
  "from": "invitation",
  "updatedAt": "2015-01-22T06:42:41.723Z",
  "createdAt": "2015-01-22T06:42:41.723Z",
  "source": "teambition",
  "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/4.png",
  "id": "54c09be1c6174f9f605b277e",
  "_teamId": "54c09be1c6174f9f605b2764",
  "team": {
    "_id": "54c09be1c6174f9f605b2764",
    "name": "team1",
    "creator": "54c09be1c6174f9f605b2762",
    "__v": 0,
    "updatedAt": "2015-01-22T06:42:41.628Z",
    "createdAt": "2015-01-22T06:42:41.628Z",
    "nonJoinable": false,
    "color": "cyan",
    "_creatorId": "54c09be1c6174f9f605b2762",
    "id": "54c09be1c6174f9f605b2764"
  }
}, {
  "__v": 0,
  "sourceId": "53febfcb2c52a0b243c594bc",
  "email": "lurenjia@teambition.com",
  "name": "lurenjia",
  "pinyin": "lurenjia",
  "_id": "54c09be1c6174f9f605b277e",
  "globalRole": "user",
  "isRobot": false,
  "pinyins": [
    "lurenjia"
  ],
  "from": "invitation",
  "updatedAt": "2015-01-22T06:42:41.723Z",
  "createdAt": "2015-01-22T06:42:41.723Z",
  "source": "teambition",
  "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/4.png",
  "id": "54c09be1c6174f9f605b277e",
  "_teamId": "54c09be1c6174f9f605b2764",
  "team": {
    "_id": "54c09be1c6174f9f605b2764",
    "name": "team1",
    "creator": "54c09be1c6174f9f605b2762",
    "__v": 0,
    "updatedAt": "2015-01-22T06:42:41.628Z",
    "createdAt": "2015-01-22T06:42:41.628Z",
    "nonJoinable": false,
    "color": "cyan",
    "_creatorId": "54c09be1c6174f9f605b2762",
    "id": "54c09be1c6174f9f605b2764"
  }
}]
```
