![SporeNetworking](https://github.com/loohawe/SporeExample/blob/master/Logo.png)

========================================================================================
# SporeNetworking

[![CI Status](http://img.shields.io/travis/loohawe@gamil.com/SporeNetworking.svg?style=flat)](https://travis-ci.org/loohawe@gamil.com/SporeNetworking)
[![Version](https://img.shields.io/cocoapods/v/SporeNetworking.svg?style=flat)](http://cocoapods.org/pods/SporeNetworking)
[![License](https://img.shields.io/cocoapods/l/SporeNetworking.svg?style=flat)](http://cocoapods.org/pods/SporeNetworking)
[![Platform](https://img.shields.io/cocoapods/p/SporeNetworking.svg?style=flat)](http://cocoapods.org/pods/SporeNetworking)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SporeNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SporeNetworking", "~> 0.1"
```

## Author

loohawe@gamil.com, luhao@mogoroom.com

## License

SporeNetworking is available under the MIT license. See the LICENSE file for more info.

## 简介

`SporeNetworking` 是实现 `POP` 面向协议编程的网络层, 旨在打造一个可热插拔的网络组件. 
是蘑菇租房 iOS 底层优化工程的一部分.

即将用作蘑菇租客, 蘑菇伙伴的网络层.



## 安装

### CocoaPod
```
pod SporeNetworking, ~> 0.1
```

### 暂不支持 Carthage

### 或者手动导入(不建议)
Clone 整个工程, 导入 `class` 文件下的所有 `Swift` 文件



## 用法

### 1. 配置 SporeNetworking 使之符合业务需求

配置内容大概有以下几个方面:
- 网络请求头文件中包含哪些固定的字段值, 比如 `agent`, `content-type` 等等 `HTTP` 协议中规定字段.
- 请求 `URL` 中是否要接入固定的参数.
- 网络安全相关的设置, 比如 `HTTP` 头字段中是否要加入相关字段做认证等等
- 每个网络请求是否有固定的参数格式
...

基于以上问题的考虑, 建议的 `SporeNetworking` 的使用方式如下:

- 定义 `MogoAPIRequest` 的协议, 继承于 `SporeNetworking` 中的 `BeRequested` 协议.
在 `extension` 中给出默认实现
各个属性或方法的含义在代码的注释中给出
```

protocol MogoAPIRequest: BeRequested {
...
}

extension MogoAPIRequest { 
/*!
网络请求 URL 的 Base URL, 也可以叫主机地址.
如果要切换网络环境, 更改此属性既可.
*/
var baseURL: URL ...

/*!
网络请求 URL 的后半部分, 此属性需要子类复写.
需要注意的是, 这部分字符串再拼接到完整 URL 后并不会进行特殊字符转义.
*/
var path: String ...

/*!
HTTP 协议的头部字段.
*/
var headerFields: [String : String] ...

/*!
设置 HTTP 头部的 "Content-type" 字段.
设置 Body 里的数据传输方式.
其中唯一的一个方法返回值将用来设置 URLRequest.httpBody 或 URLRequest.inputStream
*/
var bodyParameters: BodySerialization ...

/*!
网络请求的参数.
如果 method 为 get, delete, head , 该参数将被拼接在 URL 后边.
如果 method 为其他方式, 该参数将由 bodyParameters 决定在 body 中传输方式.
*/
final func buildParameters() -> [String : Any]? ...

/*!
网络请求有返回值后, 会首先调此方法进行业务有关的数据处理.
比如如何解析 Data 数据, 验证返回数据是否完整等等.
如果此方法中有异常, 需要 throw Response error
*/
func parseResponse(data: Data?, urlResponse: HTTPURLResponse) throws -> Response ...
```
详细设置请参考[示例代码](https://github.com/loohawe/SporeExample/blob/master/SporeExample/SporeNetworkingConfig.swift)



### 2. 业务中各个 API 声明

每个具体的 `API` 需要继承 `BaseAPI` 基类, 只需要做两件事情就可以:

1. 定义 `path`.
2. 返回此次请求的**参数**.

Example:
```
class HotBusinessAreaAPI: BeRequested {

// 定义 Path
override var path: String ...

// 返回参数
override func contentParameters() -> [String : Any] ...

}
```
详见[示例代码](https://github.com/loohawe/SporeExample/blob/master/SporeExample/APIList.swift)



### 3. 网络请求返回数据模型的定义

数据模型需要实现协议 `BeResponsed`, 该协议中需要实现从 JSON -> Model 的方法.

发起网络请求的 `session` 的 `send` 方法是个泛型方法, 调用此方法时, 需要制定返回类型.

参考[示例代码](https://github.com/loohawe/SporeExample/blob/master/SporeExample/APIList.swift)

```
struct BusinessArea: BeResponsed {

/*!
数据模型中的各种属性
*/
var list: ...

/*! 
协议 BeResponsed 中的方法, 功能从 JSON -> Model
如果有嵌套类型, 也需要在这里实现
*/
static func buildModel(response: Response) throws -> BusinessArea ...
}
```



### 4. 发起网络请求

1) 实例化一个 API 对象.
```
let loadArea: HotBusinessAreaAPI = HotBusinessAreaAPI.init()
```

2) 用`session`发起网络请求, 返回由 Result 枚举给出
```     
let _ = Session.shared.send(loadArea, callbackQueue: .main) {
(result: Result<BusinessArea, SessionTaskError>) in

print("call back")

switch result {
case .success(let user):
print("\(user)")
case .failure(let sessionError):
print("\(sessionError)")
}
}
```
[示例代码](https://github.com/loohawe/SporeExample/blob/master/SporeExample/ViewController.swift)




其中部分思路参考 APIKit 设计, `URL` 中参数拼接方式参考 Alamofire 实现.

