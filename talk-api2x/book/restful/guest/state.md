## guest/state

### summary
read the guest state of talk,
this api will reset the expire date of guest session

### method
GET

### route
> /api/state

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
</table>

### request
```
GET /api/state HTTP/1.1
```

### response
```json
{
  "ok": 1
}
```
