# lua自定义库

## class.lua创建类工具库



## connector.lua 连接器

## cluster_mgr.lua 集群节点管理

## cluster_monitor.lua 集群工具
```lua
local redis_conf = { host="127.0.0.1", port=6379, db=0 }
local node_conf = { 
	nodename="node1", 
	nodeprot=9001, 
   	intranetip="127.0.0.1", 
   	extranetip="127.1.1.1",
	use_intranet=1, 
	serverid=1, 
	servertype=1, 
	ver=0,
}
```


## dispatcher.lua rpc分派相关

## requester.lua rpc请求相关

## logger.lua 日志工具

## command_base.lua 接收skynet命令基础类

## service_base.lua 服务基础类

## session_base.lua 会话相关

## role_base.lua 玩家相关

## share_memory.lua 共享内存

## redis_mq.lua 使用redis实现的pubsub类