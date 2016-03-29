### Display Types

* message

  显示消息正文

* file

  显示文件

* image

  显示缩略图

* rtf

  显示富文本内容

* system

  显示为系统消息

* integration(rss, url, firim, jinshuju, jiankongbao, incoming, email)

  显示消息正文(content，当为空字符串时隐藏)，聚合标题(quote.title)，聚合内容(quote.text，过滤 html 标签)，图片作为头图显示在左侧(thumbnail，高度固定)

* weibo(weibo)

  同general_integration，图片作为附件显示在底部（高度固定）

* github(github, gitlab, coding)

  同general_integration，聚合内容(quote.text)作为 html 显示(不过滤 html 标签)
