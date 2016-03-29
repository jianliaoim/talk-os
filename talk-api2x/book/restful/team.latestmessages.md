## team.latestmessages

### summary
list the recent messages of the team

### method
GET

### route
> /v2/teams/:_id/latestmessages

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
GET /v2/teams/536c834d26faf71918b774ed/latestmessages HTTP/1.1
```

### response
```json
[
  {
    "_id": "54d98ef83c0b3ada1c4ccfae",
    "content": [
      "{{__info-create-file}}"
    ],
    "creator": {
      "_id": "54d98ef83c0b3ada1c4ccf93",
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
      "updatedAt": "2015-02-10T04:54:16.327Z",
      "createdAt": "2015-02-10T04:54:16.327Z",
      "source": "teambition",
      "avatarUrl": "null",
      "id": "54d98ef83c0b3ada1c4ccf93"
    },
    "room": {
      "_id": "54d98ef83c0b3ada1c4ccfa1",
      "email": "room1.rdd879290@talk.ai",
      "team": "54d98ef83c0b3ada1c4ccf95",
      "topic": "room1",
      "pinyin": "room1",
      "creator": "54d98ef83c0b3ada1c4ccf93",
      "guestToken": "dd874470",
      "__v": 0,
      "updatedAt": "2015-02-10T04:54:16.375Z",
      "createdAt": "2015-02-10T04:54:16.375Z",
      "pinyins": [
        "room1"
      ],
      "isGuestVisible": false,
      "color": "blue",
      "isPrivate": false,
      "isArchived": false,
      "isGeneral": false,
      "guestUrl": "http://guest.talk.bi/rooms/dd874470",
      "_creatorId": "54d98ef83c0b3ada1c4ccf93",
      "_teamId": "54d98ef83c0b3ada1c4ccf95",
      "id": "54d98ef83c0b3ada1c4ccfa1"
    },
    "team": "54d98ef83c0b3ada1c4ccf95",
    "file": {
      "_id": "54d98ef83c0b3ada1c4ccfac",
      "fileKey": "2a4a216c6095750ec4840925a14ebad2",
      "fileName": "file2",
      "fileType": "png",
      "creator": "54d98ef83c0b3ada1c4ccf93",
      "team": "54d98ef83c0b3ada1c4ccf95",
      "createdAt": "2015-02-10T04:54:16.394Z",
      "updatedAt": "2015-02-10T04:54:16.394Z",
      "__v": 0,
      "message": "54d98ef83c0b3ada1c4ccfae",
      "_messageId": "54d98ef83c0b3ada1c4ccfae",
      "_creatorId": "54d98ef83c0b3ada1c4ccf93",
      "_teamId": "54d98ef83c0b3ada1c4ccf95",
      "previewUrl": null,
      "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad2.png/w/400/h/400",
      "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad2.png?download=file2&e=1423547656&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:g5AiWcFTIPKuWaUYuffVIBLNxPw=",
      "id": "54d98ef83c0b3ada1c4ccfac"
    },
    "__v": 0,
    "updatedAt": "2015-02-10T04:54:16.396Z",
    "createdAt": "2015-02-10T04:54:16.396Z",
    "icon": "normal",
    "isMailable": true,
    "isPushable": true,
    "isSearchable": true,
    "isEditable": true,
    "displayMode": "normal",
    "isManual": true,
    "isStarred": false,
    "_fileId": "54d98ef83c0b3ada1c4ccfac",
    "_teamId": "54d98ef83c0b3ada1c4ccf95",
    "_roomId": "54d98ef83c0b3ada1c4ccfa1",
    "_creatorId": "54d98ef83c0b3ada1c4ccf93",
    "id": "54d98ef83c0b3ada1c4ccfae"
  }
]
```
