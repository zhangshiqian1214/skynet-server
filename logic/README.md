# lua代码文件规范

## 1.lua文件名规范, 使用小写字母加下划线:
   ```lua
   connection_mgr.lua
   data_center.lua
   ```

## 2.变量名命名规范, 使用小写字母加下划线(和数据库名保持一致):
   ```lua
   local role_info
   local account_name
   local player_id
   ```

## 3.私有变量命名规范, 使用下划线在最前面
   ```lua
   local _room_map
   local _player_list
   ```

## 4.常量命名规范, 使用大写单词加下划线:
   ```lua
   local STATUS_ONLINE
   local STATUS_OFFLINE
   ```

## 5.类名命名规范, 使用大写字母加小写字母(驼峰式命名):
   RedisMQ  
   SessionMgr  

## 6.函数命名规范, 使用小写字母加下划线:
   ```lua
   function get_player_info() end  
   function set_player_info() end  
   ```

## 7.私有函数命名规范, 使用带前下划线加小写字母:
   ```lua
   function _update_role_info() end
   function _delete_role_info() end
   ```