# 简介
本demo是动图宇宙API的使用示例，示范了动图宇宙API的三个使用场景，分别是：
- 根据用户输入即时联想场景

![img](/image/quater.png)

- 键盘搜索场景

![img](/image/keyboard.png)

- 全屏搜索场景

![img](/image/full.png)

# API
API地址为：https://open-api.dongtu.com:1443/open-api

使用到的API有三个：
- 热门标签：netword/hot
- 流行表情：trending
- 搜索：   emojis/net/search

API文档详见 http://api-doc.dongtu.com/dongtu/

# demo主要类介绍

## model
1. BQSSWebSticker：  接口中返回的表情
2. BQSSHotTag：      热门标签
3. BQSSMessage：     聊天消息

## API
1. BQSSHotTagApiManager：   热门标签 API 管理器
2. BQSSTrendingApiManager   流行表情 API 管理器
3. BQSSSearchApiManager     搜索 API 管理器

