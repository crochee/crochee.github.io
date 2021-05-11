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