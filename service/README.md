# skynet服务相关约定

## 1.服务类型, 基于service_base.lua有两种服务,是否agent服务.
     非agent服务,客户端请求是基于并发式的,如果一个coroutine也就是一个请求yeild
     后,其它的请求可以继续执行,这样的并发方式类似于多线程,如果一个数据被两个请
     求所修改,那么就不能保证数据的正确性,这是由于每个请求并不是原子性的.
     agent服务,对于此服务,所有请求都放进了队列,所以它能保证每个请求执行完毕才执
     行下一下请求.这种方式有缺点,不能处理大量的请求,所以在玩家agent中使用是
     可以的.  
  
## 2.基于非agent服务定制的有序请求类
     由于单个agent在游戏中占用比较多的内存,同时创建服务的开销比较大,所以使用非
     agent服务搭建若干个role_base类, 每个role_base类里都有一个queue,所以每个都
     是一个agent. 


## 3.对于服务节点监听端口布置
     gateserver --> tcp:5001 ws:5002 cluster:9001
     dbserver --> cluster:9002
     loginserver --> cluster:9003
     lobbyserver --> cluster:9004 http:6001
     gameserver --> cluster:9005