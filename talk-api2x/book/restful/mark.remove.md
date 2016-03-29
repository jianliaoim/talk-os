# mark.remove

Remove a mark

## Route
> DELETE /v2/marks/:_id

## Events

* [mark:remove](../event/mark.remove.html)

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |

## Request
```json
DELETE /v2/marks/5603a5fe960c492df7c1a39e HTTP/1.1
Content-Type: application/json
```

### Response
```json
{
  "_id": "565c300dcd74ca61a4d97ba5",
  "x": 1000,
  "y": 1000,
  "target": "565c300dcd74ca61a4d97ba1",
  "type": "story",
  "team": "565c300dcd74ca61a4d97b6f",
  "creator": "565c300ccd74ca61a4d97b6d",
  "__v": 0,
  "updatedAt": "2015-11-30T11:16:29.639Z",
  "createdAt": "2015-11-30T11:16:29.639Z"
}
```
