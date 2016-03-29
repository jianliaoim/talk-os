## team.members

### summary
read member list of the team

### method
GET

### route
> /v2/teams/:_id/members

### params
<table>
  <thead>
    <tr>
      <th>key</th>
      <th>type</th>
      <th>required</th>
      <th>description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>_id</td>
      <td>String(ObjectId|InUrl)</td>
      <td>true</td>
      <td>team id</td>
    </tr>
  </tbody>
</table>

### request
```
GET /v2/teams/536c834d26faf71918b774ed/members HTTP/1.1
```

### response
```json
[
  {
    "_id": "54d98ef83c0b3ada1c4ccf78",
    "name": "dajiangyou2",
    "pinyin": "dajiangyou2",
    "email": "user2@teambition.com",
    "__v": 0,
    "globalRole": "user",
    "isRobot": false,
    "pinyins": [
      "dajiangyou2"
    ],
    "from": "register",
    "updatedAt": "2015-02-10T04:54:16.218Z",
    "createdAt": "2015-02-10T04:54:16.218Z",
    "source": "teambition",
    "avatarUrl": "null",
    "id": "54d98ef83c0b3ada1c4ccf78",
    "role": "owner"
  },
  {
    "_id": "54d98ef83c0b3ada1c4ccf77",
    "name": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "email": "user1@teambition.com",
    "__v": 0,
    "globalRole": "user",
    "isRobot": false,
    "pinyins": [
      "dajiangyou1"
    ],
    "from": "register",
    "updatedAt": "2015-02-10T04:54:16.217Z",
    "createdAt": "2015-02-10T04:54:16.217Z",
    "source": "teambition",
    "avatarUrl": "null",
    "id": "54d98ef83c0b3ada1c4ccf77",
    "role": "owner"
  },
  {
    "_id": "54d98ef83c0b3ada1c4ccf77",
    "name": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "email": "user1@teambition.com",
    "__v": 0,
    "globalRole": "user",
    "isRobot": false,
    "pinyins": [
      "dajiangyou1"
    ],
    "from": "register",
    "updatedAt": "2015-02-10T04:54:16.217Z",
    "createdAt": "2015-02-10T04:54:16.217Z",
    "source": "teambition",
    "avatarUrl": "null",
    "id": "54d98ef83c0b3ada1c4ccf77",
    "role": "owner"
  }
]
```
