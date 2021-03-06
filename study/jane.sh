#!/bin/bash
set -ex

# 删除打包文件夹
rm -rf public

# 打包jane主题
hugo -t jane