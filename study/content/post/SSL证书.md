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
根据官网流程生成本地工具或者服务

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