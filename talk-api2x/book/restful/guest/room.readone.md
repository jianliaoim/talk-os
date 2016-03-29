## room.readOne

### summary
read basic infomation of the guest room

### method
GET

### route
> /api/rooms/:guestToken

### params
| key            | type               | required | description                                                  |
| -------------- | ------------------ | -------- | ------------------------------------------------------------ |
| guestToken     | String             | false    | Guest token |

### request
```
GET /api/rooms/315e9b40 HTTP/1.1
```

### response
```json
{
  "_id": "548eac3184334b00006eef19",
  "email": "room1.r315ec250@talk.ai",
  "team": "548eac3184334b00006eef0d",
  "topic": "room1",
  "pinyin": "room1",
  "creator": "548eac3184334b00006eef0b",
  "guestToken": "315e9b40",
  "__v": 0,
  "updatedAt": "2014-12-15T09:38:57.908Z",
  "createdAt": "2014-12-15T09:38:57.908Z",
  "pinyins": [
    "room1"
  ],
  "color": "blue",
  "isArchived": false,
  "isGeneral": false,
  "guestUrl": "http://guest.talk.bi/rooms/315e9b40",
  "_creatorId": "548eac3184334b00006eef0b",
  "_teamId": "548eac3184334b00006eef0d",
  "id": "548eac3184334b00006eef19",
  "isNew": true,
  "unread": 2,
  "_latestReadMessageId": null,
  "members": [
    {
      "_id": "548eac3184334b00006eef0c",
      "name": "dajiangyou2",
      "pinyin": "dajiangyou2",
      "avatarUrl": "null",
      "email": "user2@teambition.com",
      "__v": 0,
      "globalRole": "user",
      "isRobot": false,
      "pinyins": [
        "dajiangyou2"
      ],
      "from": "register",
      "updatedAt": "2014-12-15T09:38:57.844Z",
      "createdAt": "2014-12-15T09:38:57.844Z",
      "source": "teambition",
      "id": "548eac3184334b00006eef0c"
    },
    {
      "_id": "548eac3184334b00006eef0b",
      "name": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "avatarUrl": "null",
      "email": "user1@teambition.com",
      "__v": 0,
      "globalRole": "user",
      "isRobot": false,
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "updatedAt": "2014-12-15T09:38:57.843Z",
      "createdAt": "2014-12-15T09:38:57.843Z",
      "source": "teambition",
      "id": "548eac3184334b00006eef0b"
    }
  ],
  "latestMessages": [
    {
      "_id": "548eac3184334b00006eef26",
      "content": [
        "{{__info-create-file}}"
      ],
      "creator": {
        "_id": "548eac3184334b00006eef0b",
        "name": "dajiangyou1",
        "pinyin": "dajiangyou1",
        "avatarUrl": "null",
        "email": "user1@teambition.com",
        "__v": 0,
        "globalRole": "user",
        "isRobot": false,
        "pinyins": [
          "dajiangyou1"
        ],
        "from": "register",
        "updatedAt": "2014-12-15T09:38:57.843Z",
        "createdAt": "2014-12-15T09:38:57.843Z",
        "source": "teambition",
        "id": "548eac3184334b00006eef0b"
      },
      "room": {
        "_id": "548eac3184334b00006eef19",
        "email": "room1.r315ec250@talk.ai",
        "team": "548eac3184334b00006eef0d",
        "topic": "room1",
        "pinyin": "room1",
        "creator": "548eac3184334b00006eef0b",
        "guestToken": "315e9b40",
        "__v": 0,
        "updatedAt": "2014-12-15T09:38:57.908Z",
        "createdAt": "2014-12-15T09:38:57.908Z",
        "pinyins": [
          "room1"
        ],
        "color": "blue",
        "isArchived": false,
        "isGeneral": false,
        "guestUrl": "http://guest.talk.bi/rooms/315e9b40",
        "_creatorId": "548eac3184334b00006eef0b",
        "_teamId": "548eac3184334b00006eef0d",
        "id": "548eac3184334b00006eef19"
      },
      "team": "548eac3184334b00006eef0d",
      "file": {
        "_id": "548eac3184334b00006eef24",
        "fileKey": "2a4a216c6095750ec4840925a14ebad2",
        "fileName": "file2",
        "fileType": "png",
        "creator": "548eac3184334b00006eef0b",
        "team": "548eac3184334b00006eef0d",
        "createdAt": "2014-12-15T09:38:57.945Z",
        "updatedAt": "2014-12-15T09:38:57.945Z",
        "__v": 0,
        "message": "548eac3184334b00006eef26",
        "_messageId": "548eac3184334b00006eef26",
        "_creatorId": "548eac3184334b00006eef0b",
        "_teamId": "548eac3184334b00006eef0d",
        "previewUrl": null,
        "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad2.png/w/200/h/200",
        "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad2.png?download=file2&e=1418639938&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:j5mLAhHIwgoy2Koq781DiIH1QCc=",
        "id": "548eac3184334b00006eef24"
      },
      "__v": 0,
      "updatedAt": "2014-12-15T09:38:57.950Z",
      "createdAt": "2014-12-15T09:38:57.950Z",
      "isSearchable": true,
      "isEditable": true,
      "isStarred": false,
      "category": "user",
      "_fileId": "548eac3184334b00006eef24",
      "_teamId": "548eac3184334b00006eef0d",
      "_roomId": "548eac3184334b00006eef19",
      "_creatorId": "548eac3184334b00006eef0b",
      "id": "548eac3184334b00006eef26"
    },
    {
      "_id": "548eac3184334b00006eef25",
      "content": [
        "{{__info-create-file}}"
      ],
      "creator": {
        "_id": "548eac3184334b00006eef0b",
        "name": "dajiangyou1",
        "pinyin": "dajiangyou1",
        "avatarUrl": "null",
        "email": "user1@teambition.com",
        "__v": 0,
        "globalRole": "user",
        "isRobot": false,
        "pinyins": [
          "dajiangyou1"
        ],
        "from": "register",
        "updatedAt": "2014-12-15T09:38:57.843Z",
        "createdAt": "2014-12-15T09:38:57.843Z",
        "source": "teambition",
        "id": "548eac3184334b00006eef0b"
      },
      "room": {
        "_id": "548eac3184334b00006eef19",
        "email": "room1.r315ec250@talk.ai",
        "team": "548eac3184334b00006eef0d",
        "topic": "room1",
        "pinyin": "room1",
        "creator": "548eac3184334b00006eef0b",
        "guestToken": "315e9b40",
        "__v": 0,
        "updatedAt": "2014-12-15T09:38:57.908Z",
        "createdAt": "2014-12-15T09:38:57.908Z",
        "pinyins": [
          "room1"
        ],
        "color": "blue",
        "isArchived": false,
        "isGeneral": false,
        "guestUrl": "http://guest.talk.bi/rooms/315e9b40",
        "_creatorId": "548eac3184334b00006eef0b",
        "_teamId": "548eac3184334b00006eef0d",
        "id": "548eac3184334b00006eef19"
      },
      "team": "548eac3184334b00006eef0d",
      "file": {
        "_id": "548eac3184334b00006eef23",
        "fileKey": "2a4a216c6095750ec4840925a14ebad1",
        "fileName": "file1",
        "fileType": "png",
        "creator": "548eac3184334b00006eef0b",
        "team": "548eac3184334b00006eef0d",
        "createdAt": "2014-12-15T09:38:57.938Z",
        "updatedAt": "2014-12-15T09:38:57.938Z",
        "__v": 0,
        "message": "548eac3184334b00006eef25",
        "_messageId": "548eac3184334b00006eef25",
        "_creatorId": "548eac3184334b00006eef0b",
        "_teamId": "548eac3184334b00006eef0d",
        "previewUrl": null,
        "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad1.png/w/200/h/200",
        "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad1.png?download=file1&e=1418639938&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:czUsTO-SAzKCgiduM9Fy-UoozUw=",
        "id": "548eac3184334b00006eef23"
      },
      "__v": 0,
      "updatedAt": "2014-12-15T09:38:57.947Z",
      "createdAt": "2014-12-15T09:38:57.947Z",
      "isSearchable": true,
      "isEditable": true,
      "isStarred": false,
      "category": "user",
      "_fileId": "548eac3184334b00006eef23",
      "_teamId": "548eac3184334b00006eef0d",
      "_roomId": "548eac3184334b00006eef19",
      "_creatorId": "548eac3184334b00006eef0b",
      "id": "548eac3184334b00006eef25"
    }
  ]
}
```
