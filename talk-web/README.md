Talk.ai/Web
------

API 文档: http://talk.ci/doc/

### 环境

* Nginx

网页运行目前使用 Nginx 静态文件服务器, 域名 `talk.bi`.
几个路径因为在前端 Router 里指定了, 需要手动写.

配置示例: https://code.teambition.com/snippets/10

* Workstation(192.168.0.21)

API 服务器连接 workstation 获取数据.
相应域名需要在 `/etc/hosts` 配置.

如果需要查看数据:
```bash
mongo --host 192.168.0.21 talk
```

### 基本开发配置

```bash
npm i
gulp dev
```

### Gulp 使用

```bash
NODE_ENV=static gulp build # for static files
NODE_ENV=ws gulp build # for ws
NODE_ENV=beta gulp build # for beta
NODE_ENV=ga gulp build # for ga
```

npm tasks

```bash
npm run static # NODE_ENV=static gulp build
npm run ws # NODE_ENV=ws gulp build
```

Guest mode 脚本:

```bash
APP=guest gulp dev # 开发模式
APP=guest NODE_ENV=static gulp build
APP=guest NODE_ENV=ws gulp build # for ws
APP=guest NODE_ENV=ga gulp build # for ga
```

### 单元测试

暂时只支持测试store
```
npm install phantomjs-prebuilt
npm run test-dev
```

## e2e测试
安装
```
npm install -g nightwatch selenium-standalone
selenium-standalone install
```
分别运行
```
selenium-standalone start
nightwatch
```

## 界面测试
```
npm run ui-test
```
访问`localhost:9000`

### CDN

上传 CDN 之前配置 `upyun-config.coffee`:

```coffee
module.exports =
  username: ''
  password: ''
```
