Config      = require './conf'
Utility     = require './util'
crypto      = require 'crypto'
debug       = require 'debug'
express     = require 'express'
http        = require 'http'
bodyParser  = require 'body-parser'
mysql       = require 'mysql'
request     = require 'request'

log       = debug 'app:log'
logError  = debug 'app:error'

app = express()

app.use bodyParser.urlencoded extended: true

app.post '/receive', (req, res) ->
  if verifySignature(req)
    res.send 'OK!'

    setImmediate () ->
      # 只接受单聊
      if req.body.toUserId is Config.ROBOT_USER_ENCODED_ID and req.body.channelType is 'PERSON'
        # 只识别文本消息
        if req.body.objectName is 'RC:TxtMsg'
          content = getMessageContent req.body.content

          # if /^(.+)的(电话|手机)/.test content

          invokeTuling req.body.fromUserId, content
          .then (responseMessageContent) ->
            Utility.sendMessage req.body.toUserId, req.body.fromUserId, responseMessageContent
  else
    res.status(400).send 'Invalid invoke!'

# Send message interface.
# Invoke RongCloud server API to send message to specific phone.
app.post '/send', (req, res) ->
  phone = req.body.phone
  content = req.body.content

  if Utility.isEmpty phone
    return res.status(400).send 'Parameter phone can not be empty.'

  if Utility.isEmpty content
    return res.status(400).send 'Parameter content can not be empty.'

  getUserIdFromDB phone, (userId) ->
    if userId is null
      return res.status(404).send 'Can not find userId by this phone.'

    Utility.sendMessage Config.ROBOT_USER_ENCODED_ID, Utility.numberToString(userId), content, (success, resultText) ->
      if not success
        return res.status(500).send resultText

      res.send 'OK'

verifySignature = (req) ->
  appKey    = req.query.appKey
  nonce     = req.query.nonce
  timestamp = req.query.timestamp
  signature = req.query.signature

  if appKey isnt Config.RONGCLOUD_APP_KEY
    return false

  text = Config.RONGCLOUD_APP_SECRET + nonce + timestamp

  sha1 = crypto.createHash 'sha1'
  sha1.update text, 'utf8'
  result = sha1.digest 'hex'

  result is signature

getMessageContent = (jsonContent) ->
  try
    message = JSON.parse(jsonContent)

    if message and message.content
      message.content
    else
      null
  catch
    null

invokeTuling = (userId, message) ->
  message = encodeURIComponent message

  log 'Requesting Tuling robot API'

  new Promise (resolve, reject) ->
    request "http://www.tuling123.com/openapi/api?key=#{Config.TULING_API_KEY}&userid=#{userId}&info=#{message}", (error, response, body) ->

      if not error
        log 'Tuling robot response:', body

        responseBody = JSON.parse body

        resolve responseBody.text + (if responseBody.url then ' ' + responseBody.url else '')
      else
        logError 'Tuling robot API error response:', error

        reject 'Robot has stopped working this time.'

getUserIdFromDB = (phone, callback) ->
  log 'Query userId by phone number:', phone

  sqlString = "SELECT `id` FROM `users` WHERE `region` = '86' AND `phone` = ?"

  executeSQL sqlString, [phone], (results) ->
    log 'MySQL query result:', JSON.stringify results

    if results.length > 0
      callback results[0].id
    else
      callback null

executeSQL = (sqlString, values, callback) ->
  connection = mysql.createConnection
    host     : Config.DB_HOST
    user     : Config.DB_USER
    password : Config.DB_PASSWORD
    database : Config.DB_NAME

  try
    connection.connect()

    log "Execute SQL '%s' with values %s ", sqlString, values

    connection.query sqlString, values, (error, results) ->
      if error
        log 'MySQL Error:', error.code
        callback null
      else
        #log 'Value: ', JSON.stringify results
        callback results
  finally
    connection.end()

# Start port listening.
server = app.listen Config.SERVER_PORT, ->
  console.log 'SealTalk Robot Server listening at http://%s:%s in %s mode.',
    server.address().address,
    server.address().port,
    app.get('env')

module.exports = app
module.exports.invokeTuling = invokeTuling
