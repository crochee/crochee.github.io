---
title: "Redis"
date: 2021-07-06T16:11:25+08:00
lastmod: 2021-07-06T16:11:25+08:00
draft: true
keywords: ["redis"]
description: "redis"
tags: ["redis"]
categories: ["redis"]
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
## 部署方案
### 单机模式
standaloan是redis单机模式，即所有服务连接一台redis服务，该模式不适合生产。如果发生宕机，内存爆炸，就可能导致所有连接该redis的服务发生缓存失效引起雪崩
### 哨兵模式
sentinel是redis哨兵模式，是官方推荐的高可用（HA）解决方案，当用redis做master-slave的高可用方案时，假如master宕机了，redis本身
（包括它的很多客户端）都没有实现自动进行主备切换，而Redis-sentinel本身也是一个独立运行的进程，它能监控多个master-slave集群，发现master宕机后能进行切换
![alt](redis-sentinel.png)
#### 哨兵功能实现
*   monitoring:监控redsi是否正常运行
*   notification:通知application错误信息
*   failover:当某个master死掉，选择另一个slave升级为master,更新master-slave关系
*   configurationprovider:client通过sentinel获取redis地址，并在failover时更新地址
### 集群模式
同样可以实现

### 部署方案结论
redis集群方案的三种模式，其中主从复制模式能实现读写分离，但是不能自动故障转移；哨兵模式基于主从复制模式，能实现自动故障转移，达到高可用，但与主从复制模式一样，不能在线扩容，容量受限于单机的配置；Cluster模式通过无中心化架构，实现分布式存储，可进行线性扩展，也能高可用，但对于像批量操作、事务操作等的支持性不够好。三种模式各有优缺点，可根据实际场景进行选择
