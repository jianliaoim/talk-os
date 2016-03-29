# 标记消息

## 添加标记消息

1. 调用[创建消息](../restful/message.create.html)接口，必须包含 _storyId, mark 参数，返回 message 对象中包含 mark 属性，如：

```json
{
  "body": "...",
  "mark": {
    "_id": "565c300dcd74ca61a4d97ba5",
    "x": 1000,
    "y": 1000,
    "target": "565c300dcd74ca61a4d97ba1",
    "_targetId": "565c300dcd74ca61a4d97ba1",
    "text": "First mark",
    "type": "story",
    "team": "565c300dcd74ca61a4d97b6f",
    "_teamId": "565c300dcd74ca61a4d97b6f",
    "creator": "565c300ccd74ca61a4d97b6d",
    "_creatorId": "565c300ccd74ca61a4d97b6d",
    "__v": 0,
    "updatedAt": "2015-11-30T11:16:29.639Z",
    "createdAt": "2015-11-30T11:16:29.639Z"
  },
  // 其余 message 属性
}
```
## 读取所有标记

1. 调用[读取标记](../restful/mark.read.html)接口，必须包含 _targetId（story id）参数，返回该 story 下标记列表

## 读取某标记下消息

1. 调用[读取消息](../restful/message.read.html)接口，必须包含 _markId 参数，返回该标记下消息，根据 _id 倒序排列，可通过 limit，page 参数加载更多

## 移除标记

1. 调用[移除标记](../restful/mark.remove.html)接口，此操作必须由创建者(_creatorId)或团队管理员执行，此接口广播[mark:remove](../event/mark.remove.html)事件


