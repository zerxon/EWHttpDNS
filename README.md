# EWHttpDNS
这个开源项目源于天朝坑爹的DNS污染问题，之前开发iOS经常碰到一个百思不得其解的问题，发起网络请求时，偶尔会报“未能找到使用指定主机名的服务器”的错误，原因是由于DNS被污染了，导致域名解析失败，至于天朝为何污染如此严重，你懂的。此项目的原理是通过请求DNSPod的Http域名解析服务得到域名对应的ip，最后改写APP Http 请求的头部信息，从而避过DNS污染。

## Usage
#####1) 设置httpDNS实例
注意：若设置了cacheInterval，只有当调用startAsyncParse方法时，才会去判断cacheInterval是否过期，若过期则向DNSPod发起解析域名请求，因此还需在适当的地方再次调用startAsyncParse方法，如发起API请求时。由于该服务的免费版可请求次数是有限的，qps只有1000，使用缓存目的是为了节省请求次数。

```objc
EWHttpDNS *httpDNS = [EWHttpDNS shareInstance];
httpDNS.cacheInterval = 600;  //可选，设置缓存时间，默认为0，即不使用缓存
httpDNS.defaultMapping = @{@"xxx.com": @"192.168.0.6"}; //设置默认域名IP映射
[httpDNS startAsyncParse];  //开始异步解析
```
#####2) 设置请求映射
即类似Hosts文件的作用，此方法亦可单独用于开发测试环境中局域网内虚拟域名的访问
```objc
[NSURLRequest enableHostsWitMapping:httpDNS];
```
