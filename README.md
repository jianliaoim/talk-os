# 简聊开源版

[简聊](https://jianliao.com)所有业务代码的开源版本，可作任意修改

[简聊 - 产品](http://tburl.in/c888ede0/)项目包含了简聊由开始到现在的所有开发历程，设想，和设计资源，感兴趣的同学可加入项目参观或留言

## 部署

- Node 4 (`nvm use`)
- Npm 2

### 安装环境

- 简聊使用 MongoDB 作为数据库，Redis 作为缓存和消息通讯中间件。所以首先需要在本地部署 [MongoDB](https://www.mongodb.org/) 和 [Redis](http://redis.io/) 并使用默认端口号（配置文件见 config/default.coffee）。建议使用 MongoDB 3.2 和 Redis 2.8，更高版本未经过生产环境测试。
- 简聊的搜索使用 [ElasticSearch 1.6.2](https://www.elastic.co/) + [ik 中文分词插件](https://github.com/medcl/elasticsearch-analysis-ik)，代码中已经关闭了消息搜索的功能，如需打开，需要修改以下文件

  ```
  - talk-api2x/
  - server/
   - schemas/
     - search-favorite.coffee      # 删除 `return # @osv`
     - search-message.coffee       # 删除 `return # @osv`
     - search-story.coffee         # 删除 `return # @osv`
     - message.coffee              # 删除 `return # @osv`
     - favorite.coffee             # 删除 `return # @osv`
   - observers/
     - story.coffee                # 删除 `return # @osv`
  ```

- 并且在 `config/default.coffee` 中增加

  ```
  searchHost: 'localhost'
  searchPort: 9200
  searchProtocol: 'http'
  ```

- 执行 [create-search-template.sh](talk-api2x/scripts/create-search-template.sh) 创建索引结构

### 安装代码依赖

注意：请使用 node 4.x，npm 2.x 版本，并预先启动 mongodb, redis

1. 初始化安装依赖 `npm run init`（安装PhantomJS时可能会卡住）
2. 安装全局 coffee-script `npm i -g coffee-script`（并确保 coffee 命令在当前环境变量下可用）
3. 启动 mongodb，redis 后，执行代码 `npm start`
4. 访问浏览器 `http://localhost:7001`

## LICENSE

[MIT](./LICENSE)
