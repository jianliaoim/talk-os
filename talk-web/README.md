jianliao.com front-end
-------------------------------

### Short History of Tech Stack
Date | Event
---- | -----
* Jan 2014 | Backbone
* Oct 2014 | React + Flux 
* Jul 2015 | React + Immutable.js + Redux Clone

### Contributors
Orderd by starting date

Name | github
---- | ------
寸志 | https://github.com/island205
陈涌（题叶）| https://github.com/jiyinyiyong
卢泰安 | https://github.com/vagusX
王艺霖 | https://github.com/irinakk
姚天宇 | https://github.com/xiaobuu
黄品章 | https://github.com/bjmin
陈博深 | https://github.com/Boshen

### Node and npm
* Node 4
* Npm 2

### Local Development

```bash
npm i
gulp dev
```

### Gulp builds

```bash
NODE_ENV=static gulp build # for static files
NODE_ENV=ws gulp build # for ws
NODE_ENV=beta gulp build # for beta
NODE_ENV=ga gulp build # for ga
```

Guest mode:

```bash
APP=guest gulp dev # local development
APP=guest NODE_ENV=static gulp build
APP=guest NODE_ENV=ws gulp build # for ws
APP=guest NODE_ENV=ga gulp build # for ga
```

### Unit Test

```
npm run test-dev
```

## e2e Test
Install
```
npm install -g nightwatch selenium-standalone
selenium-standalone install
```
Run 
```
selenium-standalone start
```
and
```
nightwatch
```

## ui style test
```
npm run ui-test
```
Visit `localhost:9000`
