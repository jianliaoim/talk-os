# group.remove

Remove a group

## Route
> DELETE /v2/groups/:_id

## Events

* [group:remove](../event/group.remove.html)

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |

## Request
```json
DELETE /v2/groups/5603a5fe960c492df7c1a39e HTTP/1.1
Content-Type: application/json
```

### Response
```json
{
  "_id": "5678c1c19e0e9d393583e52a",
  "creator": "5678c1c19e0e9d393583e506",
  "team": "5678c1c19e0e9d393583e515",
  "name": "XXX",
  "__v": 1,
  "updatedAt": "2015-12-22T03:21:37.961Z",
  "createdAt": "2015-12-22T03:21:37.806Z",
  "members": [
    "5678c1c19e0e9d393583e506",
    "5678c1c19e0e9d393583e507"
  ],
  "_memberIds": [
    "5678c1c19e0e9d393583e506",
    "5678c1c19e0e9d393583e507"
  ],
  "_creatorId": "5678c1c19e0e9d393583e506",
  "_teamId": "5678c1c19e0e9d393583e515",
  "id": "5678c1c19e0e9d393583e52a"
}
```
