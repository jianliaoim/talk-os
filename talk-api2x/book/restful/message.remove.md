## message.remove

### summary
remove message

### method
DELETE

### route
> /v2/messages/:_id

### events
* [message:remove](../event/message.remove.html)

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
  <tbody>
  </tbody>
</table>

### request
```
DELETE /v2/messages/53993403c3bc0c47175f468a HTTP/1.1
```

### response
```
{
    "_id": "538d7d6d255600da6286865b",
    "_roomId": "538d7d6d255600da6286865b",
    "_teamId": "538d7d6d255600da6286865b"
}
```
