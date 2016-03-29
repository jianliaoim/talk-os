## integration.checkRSS

### summary
validate the feed url

### method
GET

### route
> /v2/integrations/checkrss

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
    <tr>
      <td>url</td>
      <td>String</td>
      <td>true</td>
      <td>feed url</td>
    </tr>
  </tbody>
</table>

### request
```
GET /v2/integrations/checkrss?url=http://www.douban.com/feed/group/zhuangb/discussion HTTP/1.1
```

### response
```json
{
  "title": "豆瓣: 文艺青年装逼会小组的讨论",
  "description": "豆瓣 文艺青年装逼会小组二日内的最新讨论话题"
}
```
