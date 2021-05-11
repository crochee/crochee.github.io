---
title: "SSL证书"
date: 2021-04-25T17:05:47+08:00
lastmod: 2021-04-25T17:05:47+08:00
draft: false
keywords: ["SSL","TLS"]
description: ""
tags: ["SSL","TLS"]
categories: ["SSL","TLS"]
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
TLS(Transport Layer Security）安全传输层协议,）用于在两个通信应用程序之间提供保密性和数据完整性。该标准协议是由IETF于1999年颁布，整体来说TLS非常类似SSLv3，只是对SSLv3做了些增加和修改  

### 证书预览
一般情况下,证书都是pem格式,即以pem为拓展名  
ca.pem 根证书，由根证书颁发客户端和服务端证书  
client.pem 客户端证书  
client-key.pem 客户端秘钥  
server.pem 服务端证书  
server-key.pem 服务端秘钥  
### 相关生成工具
目前自颁发证书的工具有两类，openssl,cfssl  
cfssl由golang编写，官网：https://github.com/cloudflare/cfssl  
根据官网流程生成本地工具或者服务,为了方便后续步骤最好是全部安装   
参考文档https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md
#### 1.生成CA证书和私钥
常用指令  
查看证书信息
```shell script
cfssl certinfo -cert ca.pem
```
查看csr信息
```shell script
cfssl certinfo -csr ca.csr
```
##### 生成csr配置
```shell script
# 打印csr模板文件从而进行修改
cfssl print-defaults csr > ca-csr.json
```
```shell script
# 查看内容
cat ca-csr.json
```
内容如下
```json
{
  "CN": "example.net",
  "hosts": [
    "example.net",
    "www.example.net"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "C": "US",
      "ST": "CA",
      "L": "San Francisco"
    }
  ]
}
```
修改为
```json
{
  "CN": "MySite",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "GuangDong",
      "L": "ShenZhen",
      "O": "HW",
      "OU": "BU"
    }
  ]
}
```
注释
*   csr Certificate Signing Request的英文缩写，即证书签名请求文件
*   CN Common Name，浏览器使用该字段验证网站是否合法，一般写的是域名。非常重要。浏览器使用该字段验证网站是否合法。如果是CA，这是CA生成证书的域名
*   key 生成证书的算法
*   hosts：表示哪些主机名(域名)或者IP可以使用此csr申请的证书，为空或者""表示所有的都可以使用
*   names:
    *   C 国家，一般都是填写国际通用的国家缩写
    *   L 城市，使用cert的组织所在城市
    *   O 组织或公司名称，就是使用cert的组织名称
    *   OU 具体使用cert的部门或单位，就是组织的下级名称
    *   ST 省份，使用cert的组织所在省份
##### 生成ca-key.pem、ca.csr和ca.pem
初次情况下
```shell script
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```
使用现有私钥, 重新生成
```shell script
cfssl gencert -initca -ca-key ca-key.pem ca-csr.json | cfssljson -bare ca
```
```text
2021/05/08 15:46:32 [INFO] generating a new CA key and certificate from CSR
2021/05/08 15:46:32 [INFO] generate received request
2021/05/08 15:46:32 [INFO] received CSR
2021/05/08 15:46:32 [INFO] generating key: rsa-2048
2021/05/08 15:46:32 [INFO] encoded CSR
2021/05/08 15:46:32 [INFO] signed certificate with serial number 220628825042308002764673979550323427974788427273
```
#### 配置证书生成策略，并启动ca服务
```shell script
# 打印config模板文件从而进行修改
cfssl print-defaults config > ca-config.json
```
```shell script
# 查看内容
cat ca-config.json
```
内容如下
```json
{
  "signing": {
    "default": {
      "expiry": "168h"
    },
    "profiles": {
      "www": {
        "expiry": "8760h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth"
        ]
      },
      "client": {
        "expiry": "8760h",
        "usages": [
          "signing",
          "key encipherment",
          "client auth"
        ]
      }
    }
  }
}
```
修改为
```json
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "MySite": {
        "expiry": "8760h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ]
      }
    }
  }
}
```
注释
*   default 默认策略，指定证书的默认有效期1年（8760h）
*   profiles 表示可以设置多个profile即配置
    * www
        * usages 使用选项
            * signing 表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE
            * key encipherment 密钥加密
            * server auth 表示可以用该CA对server提供的证书进行验证
            * client auth 表示可以用该CA对client提供的证书进行验证
*   auth_keys 存储key1的加密key(16进制字符串)用于鉴权,有三种填写方式:
        1.前缀为env:表示从环境变量获取  
        2.前缀为file:表示从文件获取  
        3.无:分割的情况获取原始内容  

启动CA服务
```shell script
cfssl serve -ca-key ca-key.pem -ca ca.pem -config ca-config.json
```
```text
2021/05/08 16:58:58 [INFO] endpoint '/api/v1/cfssl/info' is enabled
2021/05/08 16:58:58 [INFO] endpoint '/api/v1/cfssl/newcert' is enabled
2021/05/08 16:58:58 [INFO] setting up key / CSR generator
2021/05/08 16:58:58 [INFO] endpoint '/api/v1/cfssl/newkey' is enabled
2021/05/08 16:58:58 [INFO] endpoint '/api/v1/cfssl/certinfo' is enabled
2021/05/08 16:58:58 [WARNING] endpoint 'revoke' is disabled: cert db not configured (missing -db-config)
2021/05/08 16:58:58 [INFO] endpoint '/' is enabled
2021/05/08 16:58:58 [INFO] endpoint '/api/v1/cfssl/health' is enabled
2021/05/08 16:58:58 [INFO] Handler set up complete.
2021/05/08 16:58:58 [INFO] Now listening on 127.0.0.1:8888
```
#### 2.基于CA服务，颁发证书
类似于ca的颁发,需要小部分改动即可
对于csr，命名client-csr.json
```json
{
  "CN": "client",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "GuangDong",
      "L": "ShenZhen",
      "O": "HW",
      "OU": "BU"
    }
  ]
}           
```
生成对应的私钥client-key.pem、csr文件client.csr和证书文件client.pem
```shell script
 cfssl gencert -config ca-config.json -ca=ca.pem -ca-key=ca-key.pem -profile=MySite client-csr.json | cfssljson -bare client
```
重新签名
```shell script
 cfssl gencert -config ca-config.json client.csr | cfssljson -bare client-new
```
### golang的双向认证应用
服务端  
```go
func tlsConfig() *tls.Config {
	caPem, err := os.ReadFile("ca.pem")
	if err != nil {
		logger.Fatal(err.Error())
	}
	var certPem []byte
	if certPem, err = os.ReadFile("server.pem"); err != nil {
		logger.Fatal(err.Error())
	}
	var keyPem []byte
	if keyPem, err = os.ReadFile("server-key.pem"); err != nil {
		logger.Fatal(err.Error())
	}
	caPool := x509.NewCertPool()
	caPool.AppendCertsFromPEM(caPem)

	var certificate tls.Certificate
	if certificate, err = tls.X509KeyPair(certPem, keyPem); err != nil {
		logger.Fatalf("unable to decode tls private key data: %v", err)
	}

	return &tls.Config{
		Certificates:           []tls.Certificate{certificate},
		ClientAuth:             tls.RequireAndVerifyClientCert,
		ClientCAs:              caPool,
		CipherSuites:           []uint16{tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256},
		SessionTicketsDisabled: true,
		MinVersion:             tls.VersionTLS12,
	}
}
```
客户端  
```go
func Transport()  http.RoundTripper {
    return &http.Transport{
            			Proxy: http.ProxyFromEnvironment,
            			DialContext: (&net.Dialer{
            				Timeout:   30 * time.Second,
            				KeepAlive: 30 * time.Second,
            			}).DialContext,
            			TLSClientConfig: &tls.Config{
            				Certificates:                []tls.Certificate{certificate},
            				RootCAs:                     caPool,
            				CipherSuites:                 []uint16{tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256},
            				SessionTicketsDisabled:      true,
            				MinVersion:                  tls.VersionTLS12,
            			},
            			ForceAttemptHTTP2:     true,
            			MaxIdleConns:          100,
            			IdleConnTimeout:       90 * time.Second,
            			TLSHandshakeTimeout:   10 * time.Second,
            			ExpectContinueTimeout: 1 * time.Second,
            		}
}
```