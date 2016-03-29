# group.update

Update a group

## Route
> PUT /v2/groups/:_id

## Events

* [group:update](../event/group.update.html)

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| name           | String             | false    | Group name        |
| addMembers     | Array(ObjectId)    | false    | Add member (ids) to group |
| removeMembers  | Array(ObjectId)    | false    | Remove member (ids) from group |

## Request
```json
PUT /v2/groups/5603a5fe960c492df7c1a39e HTTP/1.1
Content-Type: application/json
{
  "name": "YYYY"
}
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
