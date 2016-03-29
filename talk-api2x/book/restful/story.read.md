# story.read

Read a list of stories

## Route
> GET /v2/stories

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _teamId        | ObjectId           | true     | Team id        |

## Request
```json
GET /v2/stories?_teamId=536c99d0460682621f7ea6e5 HTTP/1.1
```

### Response
```json
[
  {
    "_id": "5603bc0dadd1fa46ff1df4ff",
    "creator": {
      "_id": "5603bc0dadd1fa46ff1df4cb",
      "name": "dajiangyou1",
      "py": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "emailForLogin": "user1@teambition.com",
      "emailDomain": "teambition.com",
      "phoneForLogin": "13388888881",
      "__v": 0,
      "unions": [],
      "updatedAt": "2015-09-24T09:02:05.317Z",
      "createdAt": "2015-09-24T09:02:05.315Z",
      "isGuest": false,
      "isRobot": false,
      "pys": [
        "dajiangyou1"
      ],
      "pinyins": [
        "dajiangyou1"
      ],
      "from": "register",
      "avatarUrl": "null",
      "id": "5603bc0dadd1fa46ff1df4cb",
      "mobile": "13388888881",
      "email": "user1@teambition.com"
    },
    "team": "5603bc0dadd1fa46ff1df4cd",
    "category": "file",
    "data": {
      "id": "5603bc0dadd1fa46ff1df500",
      "downloadUrl": "https://striker.teambition.net/storage/2107ff00571d2cf89eebbd0ddabbdeb38fb0?download=ic_favorite_task.png&Signature=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6Ii9zdG9yYWdlLzIxMDdmZjAwNTcxZDJjZjg5ZWViYmQwZGRhYmJkZWIzOGZiMCIsImV4cCI6MTQ0MzIyNTYwMH0.NJqS1uYPB1FM9J61ZWJ8HTsSaU_m72Md7DdGBu8IT-E",
      "thumbnailUrl": "https://striker.teambition.net/thumbnail/2107ff00571d2cf89eebbd0ddabbdeb38fb0/w/200/h/200",
      "previewUrl": "",
      "fileKey": "2107ff00571d2cf89eebbd0ddabbdeb38fb0",
      "fileName": "ic_favorite_task.png",
      "fileType": "png",
      "fileSize": 2986,
      "fileCategory": "image",
      "_id": "5603bc0dadd1fa46ff1df500"
    },
    "__v": 0,
    "updatedAt": "2015-09-24T09:02:05.691Z",
    "createdAt": "2015-09-24T09:02:05.691Z",
    "activedAt": "2015-09-24T09:02:05.691Z",
    "members": [
      {
        "_id": "5603bc0dadd1fa46ff1df4cc",
        "name": "dajiangyou2",
        "py": "dajiangyou2",
        "pinyin": "dajiangyou2",
        "emailForLogin": "user2@teambition.com",
        "emailDomain": "teambition.com",
        "phoneForLogin": "13388888882",
        "__v": 0,
        "unions": [],
        "updatedAt": "2015-09-24T09:02:05.325Z",
        "createdAt": "2015-09-24T09:02:05.325Z",
        "isGuest": false,
        "isRobot": false,
        "pys": [
          "dajiangyou2"
        ],
        "pinyins": [
          "dajiangyou2"
        ],
        "from": "register",
        "avatarUrl": "null",
        "id": "5603bc0dadd1fa46ff1df4cc",
        "mobile": "13388888882",
        "email": "user2@teambition.com"
      },
      {
        "_id": "5603bc0dadd1fa46ff1df4cb",
        "name": "dajiangyou1",
        "py": "dajiangyou1",
        "pinyin": "dajiangyou1",
        "emailForLogin": "user1@teambition.com",
        "emailDomain": "teambition.com",
        "phoneForLogin": "13388888881",
        "__v": 0,
        "unions": [],
        "updatedAt": "2015-09-24T09:02:05.317Z",
        "createdAt": "2015-09-24T09:02:05.315Z",
        "isGuest": false,
        "isRobot": false,
        "pys": [
          "dajiangyou1"
        ],
        "pinyins": [
          "dajiangyou1"
        ],
        "from": "register",
        "avatarUrl": "null",
        "id": "5603bc0dadd1fa46ff1df4cb",
        "mobile": "13388888881",
        "email": "user1@teambition.com"
      }
    ],
    "isPublic": false,
    "_memberIds": [
      "5603bc0dadd1fa46ff1df4cc",
      "5603bc0dadd1fa46ff1df4cb"
    ],
    "_creatorId": "5603bc0dadd1fa46ff1df4cb",
    "_teamId": "5603bc0dadd1fa46ff1df4cd",
    "id": "5603bc0dadd1fa46ff1df4ff"
  }
]
```
