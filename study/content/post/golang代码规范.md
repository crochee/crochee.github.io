---
title: "Golang代码规范"
date: 2021-04-21T16:00:47+08:00
lastmod: 2021-04-21T16:00:47+08:00
draft: false
keywords: ["golang"]
description: "golang代码规范"
tags: ["规范"]
categories: ["规范"]
author: "crochee"

# You can also close(false) or open(true) something for this content.
# P.S. comment can only be closed
comment: false
toc: false
autoCollapseToc: false
# You can also define another contentCopyright. e.g. contentCopyright: "This is another copyright."
contentCopyright: false
reward: false
mathjax: false
---

<!--more-->
### 目录规范
参考项目https://github.com/golang-standards/project-layout  
如同linux目录都有他的职责一样，代码目录也必须符合一定规范：
-   README.md 项目说明文档，说明项目的功能等信息
-   .gitignore 包含忽略的文件内容，必须将IDE的配置，二进制文件，临时文件排除
-   .code 代码门禁配置
-	cmd/ 用来放main函数，比如cmd/{component_name}/main.go
-	conf/ 配置文件，存放程序运行时所需要的配置文件
-	docs/ 文档目录，采用 Markdown 格式的设计、使用文档，接口API等，最好用sphinx进行管理
-	pkg/ 公共基础库，可以复用，且外部工程也能可能会使用
-	internal/ 不希望被工程外的工程调用
-	test/ 放测试数据，mock用的数据等，不要放单元测试代码
-	deployments/ 部署用的编排模板，比如terraform，aos，k8s模板和helm
-	build/package 打包脚本 ，用于打包docker, rpm, deb, zip, tar.gz
-	build/ci ci用脚本，ut，静态检查等等
-	scripts/ 其余脚本
-	examples/ 例子代码
-	assets/ 工程资源， 比如图片
-	plugins/ 可扩展插拔的插件
-	resource/ rest api实现，可以用resource/v1 resource/v2 resource/v1alpha这种格式表示不同api版本
go.mod与go.sum为所有项目必备文件，允许子目录内部存在这2个文件用于组件拆分。对于库类型工程，目录可自由安排，需要遵从go编程规范。

### README规范
需要有以下信息，并且保证代码一致性

|信息 |是否必选|说明 |
|:---:|:---:|:---:|
|概述|是| |
|本地开发指南|是| |
|最小化启动配置|是| |
|监听端口|是| |
### 代码提交规范
-   [Refactor|Bugfix|Perf|Config|Test|Other #单号] 标题
-   [VisionNo:] 单号
-   [IssueTitle:] 事件标题
-   [why:根因分析]：缺陷定位根因描述 / 代码重构原因
-   [where&how:修改思路]：改动的代码文件和位置, 需求实现思路 / 缺陷解决思路
-   [how test:影响描述&测试建议]：修改点的影响描述，已经做了哪些测试，还有哪些风险点需要重点检视？
### 编码规则集
*   规则6.7  禁止在nil和closed的channel上进行接收，发送和关闭操作
*   规则 1.2: 确保有符号整数运算时不会出现溢出
*   规则 1.1：确保无符号整数运算时不会回绕
*   规则 5.5: 确保对channel是否关闭做检查
*   规则 9.2: 确保在多用户系统中创建文件时指定合适的访问许可
*   规则 3.1: 确保能释放文件句柄、DB连接和内存资源等
*   规则 9.4: 避免在共享目录操作文件
*   规则 1.3: 确保整型转换时不会出现截断错误
*   规则 9.1: 确保临时文件使用完毕后及时删除
*   规则5.1  一个目录中只包含一个包（实现一个模块的功能）
*   redundant_code[GO]
*   规则5.3  禁止使用相对路径导入（./subpackage），所有导入路径必须符合 go get 标准
*   规则 6.2：确保在并发下对共享数据对象的访问不存在数据竞争
*   规则 7.2: 禁止将敏感信息保存在日志中或将其输出到控制台及串口
*   规则6.2  一个文件只定义一个init函数
*   规则3.3  每个包(package)都必须要有包注释
*   huge_non_headerfile[GO]
*   规则6.3  一个包内的如果存在多个init函数，不能有任何的依赖关系
*   规则1.5  包名必须全部为小写单词，允许包含数字，无下划线
*   规则 7.1: 禁止将敏感信息硬编码在程序中
*   huge_cyclomatic_complexity[GO]
*   规则 3.4: 禁止SetFinalize和指针循环引用同时使用防止内存泄露
*   unsafe_function[GO]
*   规则5.2  禁止使用 . 来简化导入包的对象调用
*   规则1.4  目录名必须为全小写单词，允许包含数字，允许加中划线‘-’组合方式，但是头尾不能为中划线
*   huge_method[GO]
*   duplication_file[GO]
*   duplication_code[GO]
*   规则 5.1: 确保赋值给接口变量的对象指针有效否则应赋予无类型的nil值
*   规则 8.3: 基于哈希算法的口令安全存储必须加入盐值
*   规则 1.4: 确保整型转换时不会出现符号错误
*   规则 5.3: 必须处理类型断言的失败
*   规则 2.2: 禁止直接使用不可信数据拼接SQL语句
*   huge_folder[GO]
*   规则 7.3: 禁止在记录操作错误的日志中泄露安全敏感信息
*   规则 3.5: 禁止重复释放资源
*   规则 9.3: 确保文件路径验证前对其进行标准化
*   FeatureEnvy
*   huge_depth[GO]
*   warning_suppression[GO]
*   huge_headerfile[GO]
*   规则 7.4: 禁止序列化未加密的敏感数据
*   规则 5.2: 确保调用方法或解除引用时接口变量封装的对象指针不为空
*   规则3.5 不用的代码段直接删除，不要注释掉
*   DataClumps
*   规则1.3  文件名必须为小写单词，允许包含数字，允许加下划线‘_’组合方式
*   规则3.1  注释符与注释内容间要有1空格
*   规则 4.1: 确保正确处理函数的错误返回值
*   规则3.4  代码注释放于对应代码的上方或右边
*   规则 8.2: 禁止使用私有或者弱加密算法
*   规则3.2  文件头注释必须包含版权许可
*   规则 3.6: 确保每个协程都能退出
*   规则 6.1: 禁止在闭包中直接调用循环变量
*   规则 9.5: 确保安全地从压缩包中提取文件
