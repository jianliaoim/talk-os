# message.create

create a message, to room or direct to a member of team.
if send message to room, the request should contain '_roomId' param,
if send message to team member, the request should contain '_teamId', '_toId' param.

## method
POST

## route
> /v2/messages

## events
* [message:create](../event/message.create.html)
* [notification:update](../event/notification.update.html)

## params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| body           | String             | false    | message content |
| _roomId        | ObjectId           | false    | room id |
| _teamId        | ObjectId           | false    | team id |
| _toId          | ObjectId           | false    | target user id |
| _storyId       | ObjectId           | false    | Story id |
| attachments    | Array              | false    | Attachments group (Categories: file, speech, rtf, quote, snippet, calendar)         |
| mark           | Object             | false    | Mark point of message ({mark: {x: 100, y: 200}})|
| reservedType   | String             | false    | Reserved type of message: voice-call, etc... |
| displayType  | String   | false    | message type (value range in ['markdown', 'text']) |

## Request
```json
POST /v2/messages HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "body": "hello world"
}
```

## Response
```json
{
  "__v": 0,
  "body": "hello world",
  "room": {
    "_id": "55b89e980ceb109a50922455",
    "email": "room1.r475eced062@talk.ai",
    "team": "55b89e980ceb109a5092242a",
    "topic": "room1",
    "py": "room1",
    "pinyin": "room1",
    "creator": "55b89e970ceb109a50922427",
    "guestToken": "475e59a0",
    "__v": 0,
    "updatedAt": "2015-07-29T09:36:24.634Z",
    "createdAt": "2015-07-29T09:36:24.634Z",
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
    "popRate": 3,
    "guestUrl": "http://guest.talk.bi/rooms/475e59a0",
    "_creatorId": "55b89e970ceb109a50922427",
    "_teamId": "55b89e980ceb109a5092242a",
    "id": "55b89e980ceb109a50922455",
    "prefs": {
      "isMute": false,
      "hideMobile": false
    }
  },
  "team": "55b89e980ceb109a5092242a",
  "creator": {
    "_id": "55b89e970ceb109a50922427",
    "name": "dajiangyou1",
    "py": "dajiangyou1",
    "pinyin": "dajiangyou1",
    "email": "user1@teambition.com",
    "emailDomain": "teambition.com",
    "mobile": "13388888888",
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
    "updatedAt": "2015-07-29T09:36:23.461Z",
    "createdAt": "2015-07-29T09:36:23.460Z",
    "avatarUrl": "null",
    "id": "55b89e970ceb109a50922427"
  },
  "tags": [],
  "_id": "55b89e980ceb109a50922459",
  "updatedAt": "2015-07-29T09:36:24.748Z",
  "createdAt": "2015-07-29T09:36:24.748Z",
  "icon": "normal",
  "isSystem": false,
  "attachments": [],
  "_teamId": "55b89e980ceb109a5092242a",
  "_roomId": "55b89e980ceb109a50922455",
  "_creatorId": "55b89e970ceb109a50922427",
  "id": "55b89e980ceb109a50922459"
}
```

## Message to a story

```json
{
  "__v": 0,
  "body": "ok",
  "team": "5604f6d22b24d98f1a478852",
  "story": {
    "_id": "5604f6d22b24d98f1a478884",
    "creator": "5604f6d12b24d98f1a478850",
    "team": "5604f6d22b24d98f1a478852",
    "category": "rtf",
    "data": {
      "id": "5604f6d22b24d98f1a478885",
      "title": "title",
      "text": "text",
      "_id": "5604f6d22b24d98f1a478885"
    },
    "__v": 1,
    "updatedAt": "2015-09-25T07:25:06.772Z",
    "createdAt": "2015-09-25T07:25:06.772Z",
    "activedAt": "2015-09-25T07:25:06.772Z",
    "members": [
      "5604f6d12b24d98f1a478850",
      "5604f6d12b24d98f1a478851"
    ],
    "isPublic": true,
    "_memberIds": [
      "5604f6d12b24d98f1a478850",
      "5604f6d12b24d98f1a478851"
    ],
    "_creatorId": "5604f6d12b24d98f1a478850",
    "_teamId": "5604f6d22b24d98f1a478852",
    "id": "5604f6d22b24d98f1a478884"
  },
  "creator": {
    "_id": "5604f6d12b24d98f1a478851",
    "name": "dajiangyou2",
    "py": "dajiangyou2",
    "pinyin": "dajiangyou2",
    "emailForLogin": "user2@teambition.com",
    "emailDomain": "teambition.com",
    "phoneForLogin": "13388888882",
    "__v": 0,
    "unions": [],
    "updatedAt": "2015-09-25T07:25:05.612Z",
    "createdAt": "2015-09-25T07:25:05.612Z",
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
    "id": "5604f6d12b24d98f1a478851",
    "mobile": "13388888882",
    "email": "user2@teambition.com"
  },
  "tags": [],
  "_id": "5604f6d22b24d98f1a478886",
  "updatedAt": "2015-09-25T07:25:06.865Z",
  "createdAt": "2015-09-25T07:25:06.864Z",
  "icon": "normal",
  "isSystem": false,
  "attachments": [],
  "_storyId": "5604f6d22b24d98f1a478884",
  "_teamId": "5604f6d22b24d98f1a478852",
  "_creatorId": "5604f6d12b24d98f1a478851",
  "id": "5604f6d22b24d98f1a478886"
}
```

## Message with attachments

### Message with file

Upload a file

```json
POST /v2/messages HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "attachments": [{
    "category": "file",
    "data": {
      "fileKey": "...",
      "fileName": "xxx"
    }
  }]
}
```

### Message with speech

Upload a speech

```json
POST /v2/messages HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "attachments": [{
    "category": "speech",
    "data": {
      "fileKey": "...",
      "fileName": "xxx",
      "duration": 7  // Time duration (seconds) of the message
    }
  }]
}
```

### Message with snippet

Upload a snippet

```json
POST /v2/messages HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "attachments": [{
    "category": "snippet",
    "data": {
      "title": "xxx",
      "text": "yyy",
      "codeType": "coffeescript"
    }
  }]
}
```

### Message with rtf text

Upload a rtf text

```json
POST /v2/messages HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "attachments": [{
    "category": "rtf",
    "data": {
      "title": "xxx",
      "text": "yyy"
    }
  }]
}
```

### Message with calendar

Send a message with calendar

```json
POST /v2/messages HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "attachments": [{
    "category": "calendar",
    "data": {
      "remindAt": 1455687226162
    }
  }]
}
```

### Message with video

Upload a video

```json
POST /v2/messages HTTP/1.1
{
  "_roomId":"53915a822731262e14d806d5",
  "attachments": [{
    "category": "speech",
    "data": {
      "fileKey": "...",
      "fileName": "xxx",
      "width": 800,
      "height": 600,
      "duration": 7  // Time duration (seconds) of the message
    }
  }]
}
```
