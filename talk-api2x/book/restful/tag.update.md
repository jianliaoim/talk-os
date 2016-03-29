## tag.update

### summary
Update a tag

### method
PUT

### route
> /v2/tags/:_id

### events
* [tag:update](../event/tag.update.html)

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| name           | String             | true     | Tag name, should not equal to other tags in this team     |

### Request
```json
PUT /v2/tags/559f77adb184c4760e18e4ab HTTP/1.1
{
  "name": "新笔记"
}
```

### Response
```json
{
  "_id": "559f77adb184c4760e18e4ab",
  "creator": "559f77acb184c4760e18e478",
  "name": "新笔记",
  "team": "559f77adb184c4760e18e47b",
  "__v": 0,
  "updatedAt": "2015-07-10T07:43:41.357Z",
  "createdAt": "2015-07-10T07:43:41.339Z",
  "_creatorId": "559f77acb184c4760e18e478",
  "_teamId": "559f77adb184c4760e18e47b",
  "id": "559f77adb184c4760e18e4ab"
}
```
