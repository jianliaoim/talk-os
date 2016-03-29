# Analysis Tool for Teambition

# Usage

First, use bower to install gta:
```
bower install gta
```

Then, include the following script in your html and you are ready to go:

```
<script id="gta-main" src="bower_component/gta/lib/index.js" data-baidu="ec912ecc405ccd050e4cdf452ef4xxxx" data-google="UA-3318xxxx-1" data-mixpanel="a0378064615fc4a8c3dc1bca7a82xxxx"></script>
<script src="test.js"></script>
<script id="gta-baidu" src="https://hm.baidu.com/hm.js?ec912ecc405ccd050e4cdf452ef4xxxx" async></script>
<script id="gta-mixpanel" src="https://cdn.mxpnl.com/libs/mixpanel-2.2.min.js" async></script>
<script id="gta-google" src="https://www.google-analytics.com/analytics.js" async></script>
```

# Page View

Call the `pageview` function to record a new page view:
```
// use single object
gta.pageview({
    'page': '/my-overridden-page?id=1',
    'title': 'my overridden page'
})

// use multiple string
gta.pageview('/api/hello', '?world');
```

# Events

You can call the `event` function to track an event:
```
gta.event('button', 'click', 'nav buttons', 4)  //@params: category, action, label, value
```
Or, easily add `data-gta='event'` to a dom element as:
```
<button data-gta='event' data-label='clicked a button' data-action='click' data-category='button'>click</button>
```
If `data-label` `data-action` `data-category` `data-value` is not provided then `className` `event type` `tagName` and `html` will be used instead.

# Api Documents

* [google](https://developers.google.com/analytics/devguides/collection/analyticsjs/)
* [baidu](http://tongji.baidu.com/open/api/more?p=ref_trackPageview)
* [Mixpanel](https://mixpanel.com/help/reference)
