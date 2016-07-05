Config    = require './conf'
debug     = require 'debug'
rongCloud = require 'rongcloud-sdk'

log       = debug 'app:log'
logError  = debug 'app:error'

# 初始化融云 Server API SDK
rongCloud.init Config.RONGCLOUD_APP_KEY, Config.RONGCLOUD_APP_SECRET

class Utility
  @isEmpty: (obj) ->
    obj is '' or obj is null or obj is undefined or (Array.isArray(obj) and obj.length is 0)

  @sendMessage: (fromUserId, toUserId, content, callback) ->
    textMessage =
      content: content

    log "Send message '%s' by RongCloud server API.", content

    rongCloud.message.private.publish fromUserId, toUserId, 'RC:TxtMsg', textMessage, (err, resultText) ->
      if err
        logError 'Error: send message failed: %j', err
        return callback false, JSON.stringify err

      result = JSON.parse resultText

      if result.code isnt 200
        return callback false, resultText

      callback true

module.exports = Utility
