## service.createmessage

Create a message from third-party application

### method
POST

### route
> /v2/services/message

### events
* [message:create](../event/message.create.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| msgToken       | String             | true     | Token of message                                                          |
| content        | String/Array       | false    | message content                                                           |
| text           | String             | false    | rich text content                                                         |
| file           | Object             | false    | file object with fileKey, fileName, fileSize, etc.                        |
| quote          | Object             | false    | quote object with title, text, redirectUrl, etc.                          |

### Request
```json
POST /v2/services/message HTTP/1.1
{
  "msgToken":"c8334996-0b38-4b10-92e1-dac450a32b03",
  "content": "hello world"
}
```

### TIP: For more options please visite [message.create](message.create.html)

### Response
```json
{
  "__v": 0,
  "team": "556fe4292f5d63f32de3b18b",
  "to": {
    "_id": "556fe4292f5d63f32de3b189",
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
    "updatedAt": "2015-06-04T05:37:45.129Z",
    "createdAt": "2015-06-04T05:37:45.129Z",
    "avatarUrl": "null",
    "id": "556fe4292f5d63f32de3b189"
  },
  "creator": {
    "_id": "556fe4292f5d63f32de3b188",
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
    "updatedAt": "2015-06-04T05:37:45.116Z",
    "createdAt": "2015-06-04T05:37:45.115Z",
    "avatarUrl": "null",
    "id": "556fe4292f5d63f32de3b188"
  },
  "_id": "556fe42a2f5d63f32de3b1aa",
  "updatedAt": "2015-06-04T05:37:46.088Z",
  "createdAt": "2015-06-04T05:37:46.088Z",
  "icon": "normal",
  "isMailable": true,
  "isPushable": true,
  "isSearchable": true,
  "isEditable": true,
  "isManual": true,
  "isStarred": false,
  "attachments": [],
  "quote": {
    "title": "hello",
    "category": "thirdapp"
  },
  "displayMode": "integration",
  "_teamId": "556fe4292f5d63f32de3b18b",
  "_toId": "556fe4292f5d63f32de3b189",
  "_creatorId": "556fe4292f5d63f32de3b188",
  "id": "556fe42a2f5d63f32de3b1aa",
  "content": []
}
```
