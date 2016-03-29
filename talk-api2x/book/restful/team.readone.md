## team.readOne

### summary
read detail infomation of the team

### method
GET

### route
> /v2/teams/:_id

### params
| key            | type               | required | description                                                  |
| -------------- | ------------------ | -------- | ------------------------------------------------------------ |

### request
```
GET /v2/teams/548eaa290d485d0000af39c0 HTTP/1.1
```

### response
```json
{
  "_id": "5577ecab671c6a43502b629a",
  "name": "team1",
  "creator": "5577ecab671c6a43502b6298",
  "__v": 0,
  "updatedAt": "2015-06-10T07:52:11.721Z",
  "createdAt": "2015-06-10T07:52:11.721Z",
  "nonJoinable": false,
  "inviteCode": "9a19cb906c",
  "color": "ocean",
  "signCodeExpireAt": "2015-06-17T07:52:11.873Z",
  "signCode": "9a30fd104q",
  "prefs": {
    "isMute": false,
    "hideMobile": false
  },
  "invitations": [],
  "latestMessages": [
    {
      "_id": "5577ecab671c6a43502b62ac",
      "content": [
        "{{__info-create-file}}"
      ],
      "creator": {
        "_id": "5577ecab671c6a43502b6298",
        "name": "dajiangyou1",
        "py": "dajiangyou1",
        "pinyin": "dajiangyou1",
        "email": "user1@teambition.com",
        "emailDomain": "teambition.com",
        "__v": 0,
        "globalRole": "user",
        "hasPwd": false,
        "isActived": false,
        "isRobot": false,
        "pys": [
          "dajiangyou1"
        ],
        "pinyins": [
          "dajiangyou1"
        ],
        "from": "register",
        "updatedAt": "2015-06-10T07:52:11.716Z",
        "createdAt": "2015-06-10T07:52:11.716Z",
        "avatarUrl": "null",
        "id": "5577ecab671c6a43502b6298"
      },
      "team": "5577ecab671c6a43502b629a",
      "room": {
        "_id": "5577ecab671c6a43502b62a6",
        "email": "room1.r9a24c81164@talk.ai",
        "team": "5577ecab671c6a43502b629a",
        "topic": "room1",
        "py": "room1",
        "pinyin": "room1",
        "creator": "5577ecab671c6a43502b6298",
        "guestToken": "9a24a100",
        "__v": 0,
        "updatedAt": "2015-06-10T07:52:11.792Z",
        "createdAt": "2015-06-10T07:52:11.792Z",
        "memberCount": 1,
        "pys": [
          "room1"
        ],
        "pinyins": [
          "room1"
        ],
        "isGuestVisible": false,
        "color": "blue",
        "isPrivate": false,
        "isArchived": false,
        "isGeneral": false,
        "isNew": false,
        "popRate": 3,
        "guestUrl": "http://guest.talk.bi/rooms/9a24a100",
        "_creatorId": "5577ecab671c6a43502b6298",
        "_teamId": "5577ecab671c6a43502b629a",
        "id": "5577ecab671c6a43502b62a6"
      },
      "__v": 0,
      "updatedAt": "2015-06-10T07:52:11.831Z",
      "createdAt": "2015-06-10T07:52:11.831Z",
      "icon": "normal",
      "isMailable": true,
      "isPushable": true,
      "isSearchable": true,
      "isEditable": true,
      "isManual": true,
      "isStarred": false,
      "attachments": [],
      "file": {
        "isSpeech": false,
        "_id": "5577ecab671c6a43502b62ad",
        "fileKey": "2a4a216c6095750ec4840925a14ebad2",
        "fileName": "file2",
        "fileType": "png",
        "id": "5577ecab671c6a43502b62ad",
        "previewUrl": null,
        "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad2.png/w/400/h/400",
        "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad2.png?download=file2&e=1433926332&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:l6OjvJicHNQ4TX3d-hLdDuV0Olg="
      },
      "displayMode": "file",
      "_fileId": "5577ecab671c6a43502b62ad",
      "_teamId": "5577ecab671c6a43502b629a",
      "_roomId": "5577ecab671c6a43502b62a6",
      "_creatorId": "5577ecab671c6a43502b6298",
      "id": "5577ecab671c6a43502b62ac"
    }
  ],
  "unread": 0,
  "hasUnread": false,
  "members": [
    {
      "_id": "5577ecab671c6a43502b6298",
      "name": "dajiangyou1",
      "py": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "email": "user1@teambition.com",
      "emailDomain": "teambition.com",
      "__v": 0,
      "globalRole": "user",
      "hasPwd": false,
      "isActived": false,
      "isRobot": false,
      "pys": [
        "dajiangyou1"
      ],
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "updatedAt": "2015-06-10T07:52:11.716Z",
      "createdAt": "2015-06-10T07:52:11.716Z",
      "avatarUrl": "null",
      "_latestReadMessageId": null,
      "hasStarredMessages": false,
      "unread": 0,
      "role": "owner",
      "prefs": {
        "isMute": false,
        "hideMobile": false
      },
      "id": "5577ecab671c6a43502b6298"
    },
    {
      "_id": "5577ecab671c6a43502b6299",
      "name": "dajiangyou2",
      "py": "dajiangyou2",
      "pinyin": "dajiangyou2",
      "email": "user2@teambition.com",
      "emailDomain": "teambition.com",
      "__v": 0,
      "globalRole": "user",
      "hasPwd": false,
      "isActived": false,
      "isRobot": false,
      "pys": [
        "dajiangyou2"
      ],
      "pinyins": [
        "dajiangyou2"
      ],
      "from": "register",
      "updatedAt": "2015-06-10T07:52:11.717Z",
      "createdAt": "2015-06-10T07:52:11.717Z",
      "avatarUrl": "null",
      "_latestReadMessageId": null,
      "hasStarredMessages": false,
      "unread": 0,
      "role": "owner",
      "prefs": {
        "isMute": false,
        "hideMobile": false
      },
      "id": "5577ecab671c6a43502b6299"
    }
  ],
  "rooms": [
    {
      "_id": "5577ecbeb62b47a6de244cbc",
      "team": "5577ecab671c6a43502b629a",
      "creator": "5577ecab671c6a43502b6298",
      "pinyin": "general",
      "py": "general",
      "topic": "general",
      "__v": 0,
      "email": "general.r9a227e203p@talk.ai",
      "updatedAt": "2015-06-10T07:52:11.724Z",
      "createdAt": "2015-06-10T07:52:11.724Z",
      "memberCount": 2,
      "pys": [
        "general"
      ],
      "pinyins": [
        "general"
      ],
      "isGuestVisible": true,
      "color": "blue",
      "isPrivate": false,
      "isArchived": false,
      "isGeneral": true,
      "hasStarredMessages": false,
      "isQuit": false,
      "_latestReadMessageId": null,
      "unread": 0,
      "isNew": false,
      "prefs": {
        "isMute": false,
        "hideMobile": false
      },
      "popRate": 6,
      "_creatorId": "5577ecab671c6a43502b6298",
      "_teamId": "5577ecab671c6a43502b629a",
      "id": "5577ecbeb62b47a6de244cbc"
    },
    {
      "_id": "5577ecab671c6a43502b62a6",
      "email": "room1.r9a24c81164@talk.ai",
      "team": "5577ecab671c6a43502b629a",
      "topic": "room1",
      "py": "room1",
      "pinyin": "room1",
      "creator": "5577ecab671c6a43502b6298",
      "guestToken": "9a24a100",
      "__v": 0,
      "updatedAt": "2015-06-10T07:52:11.792Z",
      "createdAt": "2015-06-10T07:52:11.792Z",
      "memberCount": 1,
      "pys": [
        "room1"
      ],
      "pinyins": [
        "room1"
      ],
      "isGuestVisible": false,
      "color": "blue",
      "isPrivate": false,
      "isArchived": false,
      "isGeneral": false,
      "hasStarredMessages": false,
      "isQuit": false,
      "_latestReadMessageId": null,
      "unread": 0,
      "isNew": false,
      "prefs": {
        "isMute": false,
        "hideMobile": false
      },
      "popRate": 3,
      "guestUrl": "http://guest.talk.bi/rooms/9a24a100",
      "_creatorId": "5577ecab671c6a43502b6298",
      "_teamId": "5577ecab671c6a43502b629a",
      "id": "5577ecab671c6a43502b62a6"
    }
  ],
  "inviteUrl": "http://localhost:7000/v2/via/9a19cb906c",
  "_creatorId": "5577ecab671c6a43502b6298",
  "id": "5577ecab671c6a43502b629a"
}
```
