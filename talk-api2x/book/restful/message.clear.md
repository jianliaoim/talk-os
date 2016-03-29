# message.clear

Clear the message unreadNum and update _latestReadMessageId

## Route
> POST /v2/messages/clear

## Events
* [message:unread](../event/message.unread.html)
* [notification:update](../event/notification.update.html)

## Params
| key            | type               | required | description |
| -------------- | ------------------ | -------- | ------------ |
| _roomId        | ObjectId           | false    | Room id |
| _teamId        | ObjectId           | false    | Team id |
| _toId          | ObjectId           | false    | Target user id of direct message |
| _storyId       | ObjectId           | false    | Story id |
| _latestReadMessageId    | ObjectId  | false    | Latest read message id |

## Request
```
POST /v2/messages/clear HTTP/1.1
{
  "_roomId": "536c9d223888f40b20b7e278",
  "_latestReadMessageId": "536c9d223888f40b20b7e279"
}
```

## Response
```
{
  "ok": 1
}
```
