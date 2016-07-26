Config    = require './conf'
N3D       = require './n3d'
debug     = require 'debug'
rongCloud = require 'rongcloud-sdk'

log       = debug 'app:log'
logError  = debug 'app:error'

# 初始化融云 Server API SDK
rongCloud.init Config.RONGCLOUD_APP_KEY, Config.RONGCLOUD_APP_SECRET

class Utility
  @n3d = new N3D Config.N3D_KEY, 1, 4294967295

  @isEmpty: (obj) ->
    obj is '' or obj is null or obj is undefined or (Array.isArray(obj) and obj.length is 0)

  # 将字符串 Id 反解为数字 Id
  @stringToNumber: (str) ->
    try
      @n3d.decrypt str
    catch
      null

  # 将数字 Id 转换为字符串 Id
  @numberToString: (num) ->
    try
      @n3d.encrypt num
    catch
      null

  @sendMessage: (fromUserId, toUserId, content, callback) ->
    textMessage =
      content: content

    log "Send message '%s' by RongCloud server API.", content

    rongCloud.message.private.publish fromUserId, toUserId, 'RC:TxtMsg', textMessage, (err, resultText) ->
      if err
        logError 'Error: send message failed: %j', err
        callback false, JSON.stringify err if callback
        return

      result = JSON.parse resultText

      if result.code isnt 200
        callback false, resultText if callback
        return

      callback true if callback

module.exports = Utility
