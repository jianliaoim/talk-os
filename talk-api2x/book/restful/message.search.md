## message.search

### summary
search for the team messages

### method
GET/POST

### route

> /v2/messages/search

> /v2/search

### params
| key             | type                | required | description                              |
| --------------- | ------------------- | -------- | ---------------------------------------- |
| _teamId         | String(ObjectId)    | true     | Team id                                  |
| _roomId         | String(ObjectId)    | false    | Show the messages from this room         |
| _creatorId      | String(ObjectId)    | false    | Filter the messages of this creator      |
| _creatorIds     | Array(ObjectIds)    | false    | Filter the messages of these creators    |
| _toId           | String(ObjectId)    | false    | Filter the messages to this user         |
| _toIds          | Array(ObjectIds)    | false    | Filter the messages to these users       |
| type            | String              | false    | Type of messages (file, url, rtf, message, thirdapp, snippet, calendar)        |
| fileCategory    | String              | false    | Category of file (image, document, media, other)        |
| codeType        | String              | false    | Type of code        |
| q               | String              | false    | Keywords                                 |
| limit           | Number              | false    | Limitation of each query (1 ~ 100)       |
| page            | Number              | false    | Page number (1 ~ 30)                     |
| sort            | Object              | false    | Sort query (by createdAt)                |
| isDirectMessage | Boolean             | false    | Only return the direct messages (if this option is checked, _roomId will not work) |
| _tagId          | ObjectId            | false    | Tag id |
| hasTag          | Boolean             | false    | Retrun all tagged messages  |
| timeRange       | String              | false    | Created time range of messages: day, week, month, quarter |

### Request
```
GET /v2/messages/search?_teamId=536c9d223888f40b20b7e278&q=各种情况 HTTP/1.1
```

### Response
```json
{
  "total": 2,
  "messages": [
    {
      "_id": "551e64dd460a6296e8391624",
      "content": [
        "测试一只大西瓜"
      ],
      "team": "55150006d8b41a63243933f3",
      "room": {
        "_id": "551500069e5e794fc09036e2",
        "team": "55150006d8b41a63243933f3",
        "topic": "general",
        "pinyin": "general",
        "creator": "5406aef17d3a1d5d1e428666",
        "__v": 0,
        "email": "general.rf00fea70@talk.ai",
        "updatedAt": "2015-03-27T07:00:22.787Z",
        "createdAt": "2015-03-27T07:00:22.787Z",
        "memberCount": 6,
        "pinyins": [
          "general"
        ],
        "isGuestVisible": true,
        "color": "blue",
        "isPrivate": false,
        "isArchived": false,
        "isGeneral": true,
        "isNew": false,
        "popRate": 18,
        "_creatorId": "5406aef17d3a1d5d1e428666",
        "_teamId": "55150006d8b41a63243933f3",
        "id": "551500069e5e794fc09036e2"
      },
      "creator": {
        "_id": "5406aef17d3a1d5d1e428666",
        "sourceId": "5406aef19117faad54be56be",
        "source": "teambition",
        "email": "sailxjx@163.com",
        "name": "<script>alert('ok')</script",
        "__v": 10,
        "mobile": "",
        "pinyin": "<script>alert('ok')</script",
        "emailId": "sailxjx@163.com",
        "globalRole": "user",
        "hasPwd": true,
        "isActived": false,
        "isRobot": false,
        "pinyins": [
          "<script>alert('ok')</script"
        ],
        "from": "register",
        "updatedAt": "2015-03-31T10:34:04.753Z",
        "createdAt": "2014-09-03T06:02:25.959Z",
        "avatarUrl": "https://secure.gravatar.com/avatar/ba952b975bdec5ab5b4c13ac7f506904?s=200&r=pg&d=retro",
        "id": "5406aef17d3a1d5d1e428666"
      },
      "__v": 0,
      "to": null,
      "updatedAt": "2015-04-03T10:01:01.603Z",
      "createdAt": "2015-04-03T10:01:01.603Z",
      "icon": "normal",
      "isMailable": true,
      "isPushable": true,
      "isSearchable": true,
      "isEditable": true,
      "displayMode": "normal",
      "isManual": true,
      "isStarred": false,
      "attachments": [],
      "files": [],
      "_teamId": "55150006d8b41a63243933f3",
      "_toId": null,
      "_roomId": "551500069e5e794fc09036e2",
      "_creatorId": "5406aef17d3a1d5d1e428666",
      "id": "551e64dd460a6296e8391624",
      "highlight": {
        "content": [
          "测试一只大<em>西瓜</em>"
        ]
      },
      "_score": 3.750966
    },
    {
      "_id": "5523895c20b6e5d284f7cfcf",
      "content": [
        "测试两只大西瓜"
      ],
      "team": "55150006d8b41a63243933f3",
      "to": {
        "_id": "53be411f48e9ce4c2b9621f1",
        "__v": 6,
        "email": "yong@teambition.com",
        "mobile": "18621654252",
        "name": "陈涌",
        "source": "teambition",
        "sourceId": "536c7446795a0f445cf1bb7b",
        "pinyin": "chenyong",
        "emailId": "yong@teambition.com",
        "globalRole": "user",
        "hasPwd": true,
        "isActived": true,
        "isRobot": false,
        "pinyins": [
          "chenyong",
          "chenchong"
        ],
        "from": "register",
        "updatedAt": "2015-03-04T09:11:47.170Z",
        "createdAt": "2014-07-10T07:30:39.024Z",
        "avatarUrl": "http://striker.project.ci/thumbnail/05/ca/0df1aa1ab5b86e4e1abc00f99ccf.jpg/w/200/h/200",
        "id": "53be411f48e9ce4c2b9621f1"
      },
      "creator": {
        "_id": "5406aef17d3a1d5d1e428666",
        "sourceId": "5406aef19117faad54be56be",
        "source": "teambition",
        "email": "sailxjx@163.com",
        "name": "<script>alert('ok')</script",
        "__v": 10,
        "mobile": "",
        "pinyin": "<script>alert('ok')</script",
        "emailId": "sailxjx@163.com",
        "globalRole": "user",
        "hasPwd": true,
        "isActived": false,
        "isRobot": false,
        "pinyins": [
          "<script>alert('ok')</script"
        ],
        "from": "register",
        "updatedAt": "2015-03-31T10:34:04.753Z",
        "createdAt": "2014-09-03T06:02:25.959Z",
        "avatarUrl": "https://secure.gravatar.com/avatar/ba952b975bdec5ab5b4c13ac7f506904?s=200&r=pg&d=retro",
        "id": "5406aef17d3a1d5d1e428666"
      },
      "__v": 0,
      "room": null,
      "updatedAt": "2015-04-07T07:38:04.917Z",
      "createdAt": "2015-04-07T07:38:04.917Z",
      "icon": "normal",
      "isMailable": true,
      "isPushable": true,
      "isSearchable": true,
      "isEditable": true,
      "displayMode": "normal",
      "isManual": true,
      "isStarred": false,
      "attachments": [],
      "files": [],
      "_teamId": "55150006d8b41a63243933f3",
      "_toId": "53be411f48e9ce4c2b9621f1",
      "_roomId": null,
      "_creatorId": "5406aef17d3a1d5d1e428666",
      "id": "5523895c20b6e5d284f7cfcf",
      "highlight": {
        "content": [
          "测试两只大<em>西瓜</em>"
        ]
      },
      "_score": 3.750966
    }
  ]
}
```

### Examples

#### Search for specific types

```
Search for documents
GET /v2/messages/search?_teamId=536c9d223888f40b20b7e278&type=file&q=文件&fileCategory=document
```

* types:
  * file: Messages with file
  * rtf: Rich text messages
  * url: Messages with url
  * message: Messages created by users, without rtf

* fileCategory:
  * image: image
  * document: text, pdf, message
  * media: audio, video
  * other: application, font

#### Search with general filters

* Room filter (find messages from a room)

```json
GET /v2/messages/search
{
  "_teamId": "536c9d223888f40b20b7e278",
  "_roomId": "536c9d223888f40b20b7e277",
  "type": "file",
  "q": "文件"
}
```

* Direct message filter (find messages from direct messages)

```json
GET /v2/messages/search
{
  "_teamId": "536c9d223888f40b20b7e278",
  "isDirectMessage": true,
  "q": "大西瓜"
}
```

* Creator filter (find messages created by this user)

```json
GET /v2/messages/search
{
  "_teamId": "536c9d223888f40b20b7e278",
  "_creatorId": "536c9d223888f40b20b7e277",
  "q": "大西瓜"
}
```

* Creators filter and tousers filter (find messages among these users)
  **TIPS:** If you want to find direct messages between you and another person,
  you need use this with `isDirectMessage` param

```json
GET /v2/messages/search
{
  "_teamId": "536c9d223888f40b20b7e278",
  "_creatorIds": ["536c9d223888f40b20b7e277", "536c9d223888f40b20b7e276"],  // Include your id
  "_toIds": ["536c9d223888f40b20b7e277", "536c9d223888f40b20b7e276"],  // Include your id
  "isDirectMessage": true,  // Show the direct messages
  "q": "大西瓜"
}
```

* Sort by createdAt time

```json
GET /v2/messages/search
{
  "_teamId": "536c9d223888f40b20b7e278",
  "type": "file",
  "sort": {
    "createdAt": {
      "order": "desc"
    }
  }
}
```

### Testcases

* [x] general query search
* [x] room filter
* [x] chat scope filter
* [x] creator filter
* [x] creators filter
* [x] file type
  * [x] fileCategory filter
* [x] url type
* [x] rtf type
