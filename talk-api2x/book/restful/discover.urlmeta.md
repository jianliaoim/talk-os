# discover.urlmeta

Get title and description from url

## Route
> GET /v2/discover/urlmeta

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| url            | String             | true     | URL        |

## Request
```json
GET /v2/discover/urlmeta?url=https%3A%2F%2Fjianliao.com HTTP/1.1
```

### Response
```json
{
  "faviconUrl": "http://t.cn/blog/favicon.ico",
  "title": "「访客模式」",
  "text": "通过「访客模式」邀请非企业内部成员参与话题讨论",
  "imageUrl": "https://jianliao.com/blog/content/images/2014/Dec/----2--2.png"
}
```
