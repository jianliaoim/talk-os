## guest/room.join

### summary
join a room as a guest

### method
POST

### route
> /api/rooms/:guestToken/join

### events
* [room:join](../event/room.join.html)

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
      <td>guestToken</td>
      <td>String</td>
      <td>true</td>
      <td>the token of guest room</td>
    </tr>
  </tbody>
</table>

### request
```
POST /api/rooms/536c9d22d3/join HTTP/1.1
```

### response
```json
{
  "_id": "547fe9f5fd1b298b8af154f2",
  "email": "room1.r305e4491@talk.ai",
  "team": "547fe9f5fd1b298b8af154e3",
  "topic": "room1",
  "pinyin": "room1",
  "creator": "547fe9f5fd1b298b8af154e0",
  "guestToken": "305df670",
  "__v": 0,
  "updatedAt": "2014-12-04T04:58:29.591Z",
  "createdAt": "2014-12-04T04:58:29.591Z",
  "pinyins": [
    "room1"
  ],
  "color": "blue",
  "isArchived": false,
  "isGeneral": false,
  "guestUrl": "http://localhost:7000/guest/305df670",
  "_creatorId": "547fe9f5fd1b298b8af154e0",
  "_teamId": "547fe9f5fd1b298b8af154e3",
  "id": "547fe9f5fd1b298b8af154f2",
  "isNew": true,
  "members": [
    {
      "_id": "547fe9f5fd1b298b8af154e1",
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
      "updatedAt": "2014-12-04T04:58:29.461Z",
      "createdAt": "2014-12-04T04:58:29.461Z",
      "source": "teambition",
      "id": "547fe9f5fd1b298b8af154e1"
    },
    {
      "_id": "547fe9f5fd1b298b8af154e0",
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
      "updatedAt": "2014-12-04T04:58:29.459Z",
      "createdAt": "2014-12-04T04:58:29.459Z",
      "source": "teambition",
      "id": "547fe9f5fd1b298b8af154e0"
    },
    {
      "_id": "547fe9f5fd1b298b8af154df",
      "name": "guest1",
      "pinyin": "guest1",
      "email": "guest1@somedomain.com",
      "avatarUrl": "http://ok.com",
      "__v": 0,
      "globalRole": "guest",
      "isRobot": false,
      "pinyins": [
        "guest1"
      ],
      "from": "register",
      "updatedAt": "2014-12-04T04:58:29.445Z",
      "createdAt": "2014-12-04T04:58:29.443Z",
      "source": "talk",
      "id": "547fe9f5fd1b298b8af154df"
    }
  ],
  "latestMessages": [
    {
      "_id": "547fe9f5fd1b298b8af154ff",
      "content": [
        "{{__info-create-file}}"
      ],
      "creator": {
        "_id": "547fe9f5fd1b298b8af154e0",
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
        "updatedAt": "2014-12-04T04:58:29.459Z",
        "createdAt": "2014-12-04T04:58:29.459Z",
        "source": "teambition",
        "id": "547fe9f5fd1b298b8af154e0"
      },
      "room": {
        "_id": "547fe9f5fd1b298b8af154f2",
        "email": "room1.r305e4491@talk.ai",
        "team": "547fe9f5fd1b298b8af154e3",
        "topic": "room1",
        "pinyin": "room1",
        "creator": "547fe9f5fd1b298b8af154e0",
        "guestToken": "305df670",
        "__v": 0,
        "updatedAt": "2014-12-04T04:58:29.591Z",
        "createdAt": "2014-12-04T04:58:29.591Z",
        "pinyins": [
          "room1"
        ],
        "color": "blue",
        "isArchived": false,
        "isGeneral": false,
        "guestUrl": "http://localhost:7000/guest/305df670",
        "_creatorId": "547fe9f5fd1b298b8af154e0",
        "_teamId": "547fe9f5fd1b298b8af154e3",
        "id": "547fe9f5fd1b298b8af154f2"
      },
      "team": "547fe9f5fd1b298b8af154e3",
      "file": {
        "_id": "547fe9f5fd1b298b8af154fd",
        "fileKey": "2a4a216c6095750ec4840925a14ebad2",
        "fileName": "file2",
        "fileType": "png",
        "creator": "547fe9f5fd1b298b8af154e0",
        "team": "547fe9f5fd1b298b8af154e3",
        "createdAt": "2014-12-04T04:58:29.640Z",
        "updatedAt": "2014-12-04T04:58:29.640Z",
        "__v": 0,
        "message": "547fe9f5fd1b298b8af154ff",
        "_messageId": "547fe9f5fd1b298b8af154ff",
        "_creatorId": "547fe9f5fd1b298b8af154e0",
        "_teamId": "547fe9f5fd1b298b8af154e3",
        "previewUrl": null,
        "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad2.png/w/200/h/200",
        "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad2.png?download=file2&e=1417672709&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:Oau0jZxBeXjsHQ-PB2c9RSCQ0R0=",
        "id": "547fe9f5fd1b298b8af154fd"
      },
      "__v": 0,
      "updatedAt": "2014-12-04T04:58:29.645Z",
      "createdAt": "2014-12-04T04:58:29.645Z",
      "isSearchable": true,
      "isEditable": true,
      "isStarred": false,
      "category": "user",
      "_fileId": "547fe9f5fd1b298b8af154fd",
      "_teamId": "547fe9f5fd1b298b8af154e3",
      "_roomId": "547fe9f5fd1b298b8af154f2",
      "_creatorId": "547fe9f5fd1b298b8af154e0",
      "id": "547fe9f5fd1b298b8af154ff"
    },
    {
      "_id": "547fe9f5fd1b298b8af154fe",
      "content": [
        "{{__info-create-file}}"
      ],
      "creator": {
        "_id": "547fe9f5fd1b298b8af154e0",
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
        "updatedAt": "2014-12-04T04:58:29.459Z",
        "createdAt": "2014-12-04T04:58:29.459Z",
        "source": "teambition",
        "id": "547fe9f5fd1b298b8af154e0"
      },
      "room": {
        "_id": "547fe9f5fd1b298b8af154f2",
        "email": "room1.r305e4491@talk.ai",
        "team": "547fe9f5fd1b298b8af154e3",
        "topic": "room1",
        "pinyin": "room1",
        "creator": "547fe9f5fd1b298b8af154e0",
        "guestToken": "305df670",
        "__v": 0,
        "updatedAt": "2014-12-04T04:58:29.591Z",
        "createdAt": "2014-12-04T04:58:29.591Z",
        "pinyins": [
          "room1"
        ],
        "color": "blue",
        "isArchived": false,
        "isGeneral": false,
        "guestUrl": "http://localhost:7000/guest/305df670",
        "_creatorId": "547fe9f5fd1b298b8af154e0",
        "_teamId": "547fe9f5fd1b298b8af154e3",
        "id": "547fe9f5fd1b298b8af154f2"
      },
      "team": "547fe9f5fd1b298b8af154e3",
      "file": {
        "_id": "547fe9f5fd1b298b8af154fc",
        "fileKey": "2a4a216c6095750ec4840925a14ebad1",
        "fileName": "file1",
        "fileType": "png",
        "creator": "547fe9f5fd1b298b8af154e0",
        "team": "547fe9f5fd1b298b8af154e3",
        "createdAt": "2014-12-04T04:58:29.639Z",
        "updatedAt": "2014-12-04T04:58:29.639Z",
        "__v": 0,
        "message": "547fe9f5fd1b298b8af154fe",
        "_messageId": "547fe9f5fd1b298b8af154fe",
        "_creatorId": "547fe9f5fd1b298b8af154e0",
        "_teamId": "547fe9f5fd1b298b8af154e3",
        "previewUrl": null,
        "thumbnailUrl": "http://striker.project.ci/thumbnail/2a/4a/216c6095750ec4840925a14ebad1.png/w/200/h/200",
        "downloadUrl": "http://striker.project.ci/uploads/2a/4a/216c6095750ec4840925a14ebad1.png?download=file1&e=1417672709&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:O9iRkhZyi1sB7PzF9B3nHsDhxB0=",
        "id": "547fe9f5fd1b298b8af154fc"
      },
      "__v": 0,
      "updatedAt": "2014-12-04T04:58:29.642Z",
      "createdAt": "2014-12-04T04:58:29.642Z",
      "isSearchable": true,
      "isEditable": true,
      "isStarred": false,
      "category": "user",
      "_fileId": "547fe9f5fd1b298b8af154fc",
      "_teamId": "547fe9f5fd1b298b8af154e3",
      "_roomId": "547fe9f5fd1b298b8af154f2",
      "_creatorId": "547fe9f5fd1b298b8af154e0",
      "id": "547fe9f5fd1b298b8af154fe"
    }
  ]
}
```
