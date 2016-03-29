## tag.create

### summary
Create a new tag

### method
POST

### route
> /v2/tags

### events
* [tag:create](../event/tag.create.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| _teamId        | ObjectId           | true     | Team id                                                                |
| name           | String             | true     | Tag name, should not equal to other tags in this team     |

### Request
```json
POST /v2/tags HTTP/1.1
{
  "_teamId":"559f77adb184c4760e18e47b",
  "name": "团队笔记"
}
```

### Response
```json
{
  "__v": 0,
  "creator": "559f77acb184c4760e18e478",
  "name": "团队笔记",
  "team": "559f77adb184c4760e18e47b",
  "_id": "559f77adb184c4760e18e4ab",
  "updatedAt": "2015-07-10T07:43:41.340Z",
  "createdAt": "2015-07-10T07:43:41.339Z",
  "_creatorId": "559f77acb184c4760e18e478",
  "_teamId": "559f77adb184c4760e18e47b",
  "id": "559f77adb184c4760e18e4ab"
}
```
