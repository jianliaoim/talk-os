## room.readOne

### summary
read the detail infomation of a room

### method
GET

### route
> /v2/rooms/:_id

### params
| key            | type               | required | description                                                  |
| -------------- | ------------------ | -------- | ------------------------------------------------------------ |

### request
```
GET /v2/rooms/548eac3184334b00006eef19 HTTP/1.1
```

### response
```json
{
  "_id": "5513b413038e107f24940e43",
  "email": "room1.r1499edd1@talk.ai",
  "team": "5513b413038e107f24940e37",
  "topic": "room1",
  "pinyin": "room1",
  "creator": "5513b413038e107f24940e35",
  "guestToken": "1499c6c0",
  "__v": 0,
  "updatedAt": "2015-03-26T07:24:03.756Z",
  "createdAt": "2015-03-26T07:24:03.756Z",
  "memberCount": 1,
  "pinyins": [
    "room1"
  ],
  "isGuestVisible": false,
  "color": "blue",
  "isPrivate": false,
  "isArchived": false,
  "isGeneral": false,
  "unread": 0,
  "latestMessages": [
    {
      "_id": "5513b413038e107f24940e50",
      "content": [
        "{{__info-create-file}}"
      ],
      "creator": {
        "_id": "5513b413038e107f24940e35",
        "name": "dajiangyou1",
        "pinyin": "dajiangyou1",
        "email": "user1@teambition.com",
        "__v": 0,
        "globalRole": "user",
        "hasPwd": false,
        "isActived": false,
        "isRobot": false,
        "pinyins": [
          "dajiangyou1"
        ],
        "from": "register",
        "updatedAt": "2015-03-26T07:24:03.699Z",
        "createdAt": "2015-03-26T07:24:03.699Z",
        "avatarUrl": "null",
        "id": "5513b413038e107f24940e35"
      },
      "room": {
        "_id": "5513b413038e107f24940e43",
        "email": "room1.r1499edd1@talk.ai",
        "team": "5513b413038e107f24940e37",
        "topic": "room1",
        "pinyin": "room1",
        "creator": "5513b413038e107f24940e35",
        "guestToken": "1499c6c0",
        "__v": 0,
        "updatedAt": "2015-03-26T07:24:03.756Z",
        "createdAt": "2015-03-26T07:24:03.756Z",
        "memberCount": 1,
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
        "guestUrl": "http://guest.talk.bi/rooms/1499c6c0",
        "_creatorId": "5513b413038e107f24940e35",
        "_teamId": "5513b413038e107f24940e37",
        "id": "5513b413038e107f24940e43"
      },
      "team": "5513b413038e107f24940e37",
      "file": {
        "_id": "5513b413038e107f24940e4e",
        "fileKey": "2a4a216c6095750ec4840925a14ebad2",
        "fileName": "file2",
        "fileType": "png",
        "creator": "5513b413038e107f24940e35",
        "team": "5513b413038e107f24940e37",
        "__v": 0,
        "message": "5513b413038e107f24940e50",
        "_messageId": "5513b413038e107f24940e50",
        "_creatorId": "5513b413038e107f24940e35",
        "_teamId": "5513b413038e107f24940e37",
        "previewUrl": null,
        "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad2.png/w/400/h/400",
        "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad2.png?download=file2&e=1427358244&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:4Hgvjx9OgBSUrEOW06HT32gMCdE=",
        "id": "5513b413038e107f24940e4e"
      },
      "__v": 0,
      "updatedAt": "2015-03-26T07:24:03.881Z",
      "createdAt": "2015-03-26T07:24:03.881Z",
      "icon": "normal",
      "isMailable": true,
      "isPushable": true,
      "isSearchable": true,
      "isEditable": true,
      "displayMode": "normal",
      "isManual": true,
      "isStarred": false,
      "_fileId": "5513b413038e107f24940e4e",
      "_teamId": "5513b413038e107f24940e37",
      "_roomId": "5513b413038e107f24940e43",
      "_creatorId": "5513b413038e107f24940e35",
      "id": "5513b413038e107f24940e50"
    },
    {
      "_id": "5513b413038e107f24940e4f",
      "content": [
        "{{__info-create-file}}"
      ],
      "creator": {
        "_id": "5513b413038e107f24940e35",
        "name": "dajiangyou1",
        "pinyin": "dajiangyou1",
        "email": "user1@teambition.com",
        "__v": 0,
        "globalRole": "user",
        "hasPwd": false,
        "isActived": false,
        "isRobot": false,
        "pinyins": [
          "dajiangyou1"
        ],
        "from": "register",
        "updatedAt": "2015-03-26T07:24:03.699Z",
        "createdAt": "2015-03-26T07:24:03.699Z",
        "avatarUrl": "null",
        "id": "5513b413038e107f24940e35"
      },
      "room": {
        "_id": "5513b413038e107f24940e43",
        "email": "room1.r1499edd1@talk.ai",
        "team": "5513b413038e107f24940e37",
        "topic": "room1",
        "pinyin": "room1",
        "creator": "5513b413038e107f24940e35",
        "guestToken": "1499c6c0",
        "__v": 0,
        "updatedAt": "2015-03-26T07:24:03.756Z",
        "createdAt": "2015-03-26T07:24:03.756Z",
        "memberCount": 1,
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
        "guestUrl": "http://guest.talk.bi/rooms/1499c6c0",
        "_creatorId": "5513b413038e107f24940e35",
        "_teamId": "5513b413038e107f24940e37",
        "id": "5513b413038e107f24940e43"
      },
      "team": "5513b413038e107f24940e37",
      "file": {
        "_id": "5513b413038e107f24940e4d",
        "fileKey": "2a4a216c6095750ec4840925a14ebad1",
        "fileName": "file1",
        "fileType": "png",
        "creator": "5513b413038e107f24940e35",
        "team": "5513b413038e107f24940e37",
        "__v": 0,
        "message": "5513b413038e107f24940e4f",
        "_messageId": "5513b413038e107f24940e4f",
        "_creatorId": "5513b413038e107f24940e35",
        "_teamId": "5513b413038e107f24940e37",
        "previewUrl": null,
        "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad1.png/w/400/h/400",
        "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad1.png?download=file1&e=1427358244&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:apOljSl4KAxtlxwBbw6qZ1Sndo0=",
        "id": "5513b413038e107f24940e4d"
      },
      "__v": 0,
      "updatedAt": "2015-03-26T07:24:03.812Z",
      "createdAt": "2015-03-26T07:24:03.811Z",
      "icon": "normal",
      "isMailable": true,
      "isPushable": true,
      "isSearchable": true,
      "isEditable": true,
      "displayMode": "normal",
      "isManual": true,
      "isStarred": false,
      "_fileId": "5513b413038e107f24940e4d",
      "_teamId": "5513b413038e107f24940e37",
      "_roomId": "5513b413038e107f24940e43",
      "_creatorId": "5513b413038e107f24940e35",
      "id": "5513b413038e107f24940e4f"
    }
  ],
  "members": [
    {
      "_id": "5513b413038e107f24940e36",
      "name": "dajiangyou2",
      "pinyin": "dajiangyou2",
      "email": "user2@teambition.com",
      "__v": 0,
      "globalRole": "user",
      "hasPwd": false,
      "isActived": false,
      "isRobot": false,
      "pinyins": [
        "dajiangyou2"
      ],
      "from": "register",
      "updatedAt": "2015-03-26T07:24:03.705Z",
      "createdAt": "2015-03-26T07:24:03.705Z",
      "avatarUrl": "null",
      "prefs": {
        "isMute": false
      },
      "id": "5513b413038e107f24940e36"
    },
    {
      "_id": "5513b413038e107f24940e35",
      "name": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "email": "user1@teambition.com",
      "__v": 0,
      "globalRole": "user",
      "hasPwd": false,
      "isActived": false,
      "isRobot": false,
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "updatedAt": "2015-03-26T07:24:03.699Z",
      "createdAt": "2015-03-26T07:24:03.699Z",
      "avatarUrl": "null",
      "prefs": {
        "isMute": true,
        "alias": "ALICE"
      },
      "id": "5513b413038e107f24940e35"
    }
  ],
  "isNew": false,
  "prefs": {
    "isMute": true,
    "alias": "ALICE"
  },
  "popRate": 3,
  "guestUrl": "http://guest.talk.bi/rooms/1499c6c0",
  "_creatorId": "5513b413038e107f24940e35",
  "_teamId": "5513b413038e107f24940e37",
  "id": "5513b413038e107f24940e43"
}
```
