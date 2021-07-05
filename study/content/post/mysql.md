---
title: "Mysql"
date: 2021-07-05T11:19:33+08:00
lastmod: 2021-07-05T11:19:33+08:00
draft: false
keywords: ["mysql"]
description: "mysql"
tags: ["mysql"]
categories: ["mysql"]
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
## 日志
*   重做日志（redo log）
*   回滚日志（undo log）
*   二进制日志（binlog）
*   错误日志（errorlog）
*   慢查询日志（slow query log）
*   一般查询日志（general log）
*   中继日志（relay log）
### 重做日志（redo log）
**作用**  
确保事务的持久性。防止在发生故障的时间点，尙有脏页未写入磁盘，在重启mysql服务的时候，依照redo log进行重放，从而达成事务的持久性  
**内容**  
物理格式的日志，记录的是物理数据页的修改信息，redo log是顺序写入redo log file的物理文件中的  
**产生时间**  
事务开始之后就产生redo log,redo log的落盘并不是随着事务的提交才写入的，而是在事务的执行过程中，便开始写入redo log文件  
**释放时间**  
当对应事务的脏页写入磁盘后，redo log的使命就完成了，重做日志占用的空间就可以重用（被覆盖）  
**对应的物理文件**  
默认情况下，位于数据库的data目录下的ib_logfile1&ib_logfile2
*   innodb_log_group_home_dir 指定日志文件所在的路径，默认/，表示在数据库的数据目录下
*   innodb_log_files_in_group 指定重做日志文件组中文件的数量，默认2
*   innodb_log_file_size重做日志文件的大小
*   innodb_mirrored_log_groups 指定日志镜像文件组的数量，默认1

### 回滚日志（undo log）
**作用**  
确保在事务发生之前的数据版本，可以用于回滚，同时可以提供多版本并发控制下的读（mvcc）,也即非锁定读  
**内容**  
逻辑格式的日志，在执行undo的时候，仅仅是将数据从逻辑上恢复至事务之前的状态，而不是从物理层面上操作实现的，这点不同于redo log  
**产生时间**  
事务开始之前，将当前的版本生成undo log，undo也会产生redo来保证undo的可靠性  
**释放时间**  
当事务提交后，undo log并不能立马被删除，而是放入待清理的链表，由purge线程判断是否由其他事务在使用undo段中表的上一个事务之前的版本信息，
决定是否可以清理undo log的日志空间
### 二进制日志（binlog）
**作用**  
用于复制，在主从复制中，从库利用从库上的binlog进行重放，实现主从同步。用于数据库的基于时间点的还原。  
**内容**  
逻辑格式的日志，简单任务就是执行过的事务中的sql语句。但又不完全是sql语句这么简单，而是包括了执行的sql语句（增删改）反向的信息  
**产生时间**  
事务提交的时候，一次性将事务的sql语句按照一点的格式记录到binlog中。对于较大事务的提交，可能会变得比较慢，这是因为binlog是在事务提交的时候一次性写入造成的  
**释放时间**  
binlog的默认是保持时间由参数expire_logs_days配置，也就是说对于非活动的日志文件，在生成时间超过expire_logs_days配置的天数之后，会被自动删除