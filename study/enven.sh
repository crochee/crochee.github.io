#!/bin/bash
set -ex

# 删除打包文件夹
rm -rf public

# 打包even 是主题
hugo -t even