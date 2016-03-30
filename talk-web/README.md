Talk.ai/Web
------

* Node 0.12
* Npm 2

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

```
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
