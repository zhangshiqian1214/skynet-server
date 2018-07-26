# skynet-server
用skynet搭建的服务端框架,架构使用棋牌大厅游戏的架构, 当然也可以用做全球同服的RPG游戏服务端  
支持分布式布署, 网关和游戏服务可以是动态调整的  
支持sproto协议, 兼容protobuf, 只需要做小小改动可以替换为protobuf  
支持websocket和TCP协议, 客户端底层更换网络层, 上层业务协议不需要改变  
支持https, 使用openssl和libcurl, 可以使用https做为第三方sdk接入  
支持redis缓存mysql数据库落地

## 1.编译
  $git clone https://github.com/zhangshiqian1214/skynet-server.git  
  $cd skynet-server
  $make

## 2.运行
  $./run.sh

## 3.停止
  $./stop.sh

## 4.杀死
  $./killnode.sh node


## 注意 本项目仅供参考，这只是早期自已的想法的实现，skynet是一个自由的工具，尽可以自已把自已的想法去实现，所以最好不要应用于线上，另外关于我自已多次想法的实践，尽量把代码越简单越好
