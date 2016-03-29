## message.unstar

### summary
unstar the message

this method will broadcast the new message object and a `hasStarredMessages` property of room or member

### method
POST

### route
> /v2/messages/:_id/unstar

### events
* [message:create](../event/message.create.html)
* [room:update](../event/room.update.html)
* [member:update](../event/member.update.html)

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
  </tbody>
</table>

### request
```
POST /v2/messages/54645b94b076606f4ded3866/unstar HTTP/1.1
```

### response
```json
{
  "_id": "54645b94b076606f4ded3866",
  "room": {
    "_id": "53cf26362b6b8c1f7624b1ba",
    "__v": 0,
    "creator": "53be411f48e9ce4c2b9621f1",
    "purpose": "max",
    "team": "53be411f48e9ce4c2b9621f4",
    "topic": "微博聚合",
    "email": "weibojuhe.r68c17843@talk.ai",
    "updatedAt": "2014-10-21T06:39:00.919Z",
    "createdAt": "2014-07-23T03:04:22.786Z",
    "color": "blue",
    "isArchived": false,
    "isGeneral": false,
    "pinyins": [
      "weibojuhe"
    ],
    "pinyin": "weibojuhe",
    "_creatorId": "53be411f48e9ce4c2b9621f1",
    "_teamId": "53be411f48e9ce4c2b9621f4",
    "id": "53cf26362b6b8c1f7624b1ba"
  },
  "content": [
    "ok"
  ],
  "team": "53be411f48e9ce4c2b9621f4",
  "creator": {
    "_id": "540041f1b5708f6722038a4f",
    "__v": 0,
    "avatarUrl": "https://secure.gravatar.com/avatar/1fcf44dc4b534d34425e95159887e588?s=200&r=pg&d=retro",
    "email": "jingxin@teambition.com",
    "mobile": "",
    "name": "许晶鑫",
    "sourceId": "53fec0869117faad54be56b3",
    "isRobot": false,
    "from": "register",
    "updatedAt": "2014-10-27T05:21:20.632Z",
    "createdAt": "2014-08-29T09:03:45.614Z",
    "source": "teambition",
    "pinyins": [
      "xujingxin",
      "hujingxin"
    ],
    "pinyin": "xujingxin",
    "id": "540041f1b5708f6722038a4f"
  },
  "__v": 0,
  "starredBy": {
    "_id": "540041f1b5708f6722038a4f",
    "__v": 0,
    "avatarUrl": "https://secure.gravatar.com/avatar/1fcf44dc4b534d34425e95159887e588?s=200&r=pg&d=retro",
    "email": "jingxin@teambition.com",
    "mobile": "",
    "name": "许晶鑫",
    "sourceId": "53fec0869117faad54be56b3",
    "isRobot": false,
    "from": "register",
    "updatedAt": "2014-10-27T05:21:20.632Z",
    "createdAt": "2014-08-29T09:03:45.614Z",
    "source": "teambition",
    "pinyins": [
      "xujingxin",
      "hujingxin"
    ],
    "pinyin": "xujingxin",
    "id": "540041f1b5708f6722038a4f"
  },
  "updatedAt": "2014-11-13T07:19:48.622Z",
  "createdAt": "2014-11-13T07:19:48.622Z",
  "isSearchable": true,
  "isEditable": true,
  "isStarred": true,
  "category": "user",
  "_starredById": "540041f1b5708f6722038a4f",
  "_teamId": "53be411f48e9ce4c2b9621f4",
  "_roomId": "53cf26362b6b8c1f7624b1ba",
  "_creatorId": "540041f1b5708f6722038a4f",
  "id": "54645b94b076606f4ded3866"
}
```
