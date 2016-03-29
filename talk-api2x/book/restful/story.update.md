# story.update

Update a story

## Route
> PUT /v2/stories/:_id

## Events

* [story:update](../event/story.update.html)
* [notification:update](../event/notification.update.html)
* [message:create](../event/message.create.html)

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| category       | String             | true     | Category of story  |
| data           | Object             | true     | Data of this type of story |
| isPublic       | Boolean            | false    | Visibility of story (default: true) |
| addMembers     | Array(ObjectId)    | false    | Add member (ids) to story |
| removeMembers  | Array(ObjectId)    | false    | Remove member (ids) from story |

## Request
```json
PUT /v2/stories/5603a5fe960c492df7c1a39e HTTP/1.1
Content-Type: application/json
{
  "category": "file",
  "data": {
    "fileKey": "536c834d26faf71918b774ea536c834d26faf71918b774ea",
    "fileName": "picture_name.png"
  }
}
```

### Response
```json
{
  "__v": 0,
  "creator": {
    "_id": "5603a5fe960c492df7c1a36a",
    "name": "dajiangyou1",
    "py": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "emailForLogin": "user1@teambition.com",
    "emailDomain": "teambition.com",
    "phoneForLogin": "13388888881",
    "__v": 0,
    "unions": [],
    "updatedAt": "2015-09-24T07:27:58.110Z",
    "createdAt": "2015-09-24T07:27:58.109Z",
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
    "id": "5603a5fe960c492df7c1a36a",
    "mobile": "13388888881",
    "email": "user1@teambition.com"
  },
  "category": "file",
  "data": {
    "id": "5603a5fe960c492df7c1a39f",
    "downloadUrl": "https://striker.teambition.net/storage/2107ff00571d2cf89eebbd0ddabbdeb38fb0?download=ic_favorite_task.png&Signature=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6Ii9zdG9yYWdlLzIxMDdmZjAwNTcxZDJjZjg5ZWViYmQwZGRhYmJkZWIzOGZiMCIsImV4cCI6MTQ0MzIyNTYwMH0.NJqS1uYPB1FM9J61ZWJ8HTsSaU_m72Md7DdGBu8IT-E",
    "thumbnailUrl": "https://striker.teambition.net/thumbnail/2107ff00571d2cf89eebbd0ddabbdeb38fb0/w/200/h/200",
    "previewUrl": "",
    "_id": "5603a5fe960c492df7c1a39f",
    "fileCategory": "image",
    "fileSize": 2986,
    "fileType": "png",
    "fileName": "ic_favorite_task.png",
    "fileKey": "2107ff00571d2cf89eebbd0ddabbdeb38fb0"
  },
  "team": "5603a5fe960c492df7c1a38f",
  "_id": "5603a5fe960c492df7c1a39e",
  "updatedAt": "2015-09-24T07:27:58.597Z",
  "createdAt": "2015-09-24T07:27:58.597Z",
  "activedAt": "2015-09-24T07:27:58.597Z",
  "members": [
    {
      "_id": "5603a5fe960c492df7c1a36b",
      "name": "dajiangyou2",
      "py": "dajiangyou2",
      "pinyin": "dajiangyou2",
      "emailForLogin": "user2@teambition.com",
      "emailDomain": "teambition.com",
      "phoneForLogin": "13388888882",
      "__v": 0,
      "unions": [],
      "updatedAt": "2015-09-24T07:27:58.118Z",
      "createdAt": "2015-09-24T07:27:58.118Z",
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
      "id": "5603a5fe960c492df7c1a36b",
      "mobile": "13388888882",
      "email": "user2@teambition.com"
    },
    {
      "_id": "5603a5fe960c492df7c1a36a",
      "name": "dajiangyou1",
      "py": "dajiangyou1",
      "pinyin": "dajiangyou1",
      "emailForLogin": "user1@teambition.com",
      "emailDomain": "teambition.com",
      "phoneForLogin": "13388888881",
      "__v": 0,
      "unions": [],
      "updatedAt": "2015-09-24T07:27:58.110Z",
      "createdAt": "2015-09-24T07:27:58.109Z",
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
      "id": "5603a5fe960c492df7c1a36a",
      "mobile": "13388888881",
      "email": "user1@teambition.com"
    }
  ],
  "isPublic": false,
  "_memberIds": [
    "5603a5fe960c492df7c1a36b",
    "5603a5fe960c492df7c1a36a"
  ],
  "_creatorId": "5603a5fe960c492df7c1a36a",
  "_teamId": "5603a5fe960c492df7c1a38f",
  "id": "5603a5fe960c492df7c1a39e"
}
```
