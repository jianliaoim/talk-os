# mark.read

Read a list of marks

## Route
> GET /v2/marks

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _targetId      | ObjectId           | true     | Story id       |

## Request
```json
GET /v2/marks?_targetId=536c99d0460682621f7ea6e5 HTTP/1.1
```

### Response
```json
[
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
]
```
