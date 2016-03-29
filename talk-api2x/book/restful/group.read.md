# group.read

Read a list of groups

## Route
> GET /v2/groups

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _teamId        | ObjectId           | true     | Team id        |

## Request
```json
GET /v2/groups?_teamId=536c99d0460682621f7ea6e5 HTTP/1.1
```

### Response
```json
[
  {
    "_id": "5678c1c19e0e9d393583e52a",
    "creator": "5678c1c19e0e9d393583e506",
    "team": "5678c1c19e0e9d393583e515",
    "name": "XXX",
    "__v": 0,
    "updatedAt": "2015-12-22T03:21:37.806Z",
    "createdAt": "2015-12-22T03:21:37.806Z",
    "members": [
      "5678c1c19e0e9d393583e506"
    ],
    "_memberIds": [
      "5678c1c19e0e9d393583e506"
    ],
    "_creatorId": "5678c1c19e0e9d393583e506",
    "_teamId": "5678c1c19e0e9d393583e515",
    "id": "5678c1c19e0e9d393583e52a"
  }
]
```
