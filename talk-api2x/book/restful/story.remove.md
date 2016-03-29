# story.remove

Remove a story

## Route
> DELETE /v2/stories/:_id

## Events

* [story:remove](../event/story.remove.html)
* [notification:remove](../event/notification.remove.html)

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |

## Request
```json
DELETE /v2/stories/5603a5fe960c492df7c1a39e HTTP/1.1
Content-Type: application/json
```

### Response
```json
{
  "__v": 0,
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
    "5603a5fe960c492df7c1a36b",
    "5603a5fe960c492df7c1a36a"
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
