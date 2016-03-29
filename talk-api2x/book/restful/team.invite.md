## team.invite

Invite user to team by email, _userId or mobile

### Route
> POST /v2/teams/:_id/invite

### Events

* When user is existing [team:join](../event/team.join.html)
* When user is nonexistent [invitation:create](../event/invitation.create.html)

### Params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| email          | String             | false    | User's email address |
| mobile         | String             | false    | User's phone number |
| _userId        | String(ObjectId)   | false    | User's id |

### Request
```
POST /v2/teams/54c09be1c6174f9f605b2764/invite HTTP/1.1
{
  email: 'dajiangyou@teambition.com'
}
```

### Response
```json
{
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
}
```

> When the invitee is nonexistent in talk, you'll receive a `invitation` object instead of a `user` object, which have a `isInvite` property.

```json
{
  "__v": 0,
  "mobile": "13100000000",
  "team": {
    "_id": "55efec42e212b7f8446de069",
    "name": "team1",
    "creator": "55efec41e212b7f8446de067",
    "__v": 0,
    "updatedAt": "2015-09-09T08:22:26.534Z",
    "createdAt": "2015-09-09T08:22:26.534Z",
    "nonJoinable": false,
    "inviteCode": "e76761505s",
    "color": "ocean",
    "hasUnread": false,
    "inviteUrl": "http://localhost:7000/v2/via/e76761505s",
    "_creatorId": "55efec41e212b7f8446de067",
    "id": "55efec42e212b7f8446de069"
  },
  "key": "mobile_13100000000",
  "name": "13100000000",
  "_id": "55efec43e212b7f8446de0a0",
  "updatedAt": "2015-09-09T08:22:27.017Z",
  "createdAt": "2015-09-09T08:22:27.017Z",
  "isInvite": true,
  "role": "member",
  "_teamId": "55efec42e212b7f8446de069",
  "id": "55efec43e212b7f8446de0a0"
}
```

> When inviting a non-existent user using email instead of phoneNumber. You will get a `invitation` object, in which `email` property is equal to input and `name` property is the local part of email address. BTW, the redirect link will be a team's invite link instead of team's link.

```json
{
  "__v":0,
  "email":"jianliao@teambition.com",
  "team":
  {
    "_id":"56721d7108f3be2cfea1e009",
    "name":"team1",
    "creator":"56721d7108f3be2cfea1e007",
    "__v":0,
    "updatedAt":"2015-12-17T02:26:57.814Z",
    "createdAt":"2015-12-17T02:26:57.814Z",
    "nonJoinable":false,
    "inviteCode":"a56463605a",
    "color":"ocean",
    "hasUnread":false,
    "inviteUrl":"http://localhost:7000/page/invite/a56463605a",
    "_creatorId":"56721d7108f3be2cfea1e007",
    "id":"56721d7108f3be2cfea1e009"
  },
  "key":"email_jianliao@teambition.com",
  "name":"jianliao",
  "_id":"56721d7208f3be2cfea1e03b",
  "updatedAt":"2015-12-17T02:26:58.921Z",
  "createdAt":"2015-12-17T02:26:58.921Z",
  "role":"member",
  "isInvite":true,
  "_teamId":"56721d7108f3be2cfea1e009",
  "id":"56721d7208f3be2cfea1e03b"
}
```