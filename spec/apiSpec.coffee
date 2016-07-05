Config = require '../src/conf'

describe 'Test robot.', ->
  # _global = null
  #
  # beforeAll ->
  #   _global = this

  describe 'Test receiving message.', ->

    it 'Correct.', (done) ->
      this.testPOSTAPI "/receive?appKey=#{Config.RONGCLOUD_APP_KEY}&nonce=844551300&timestamp=1467557868712&signature=13fe1fc1e9ee4f2fb6d8a671955858bc442d4f3d",
        channelType: 'PERSON'
        objectName: 'RC:TxtMsg'
        toUserId: Config.ROBOT_USER_ENCODED_ID
        content: '{"content":"hello world"}'
      , 200
      , null
      , done

    it 'Message content is not valid JSON.', (done) ->
      this.testPOSTAPI "/receive?appKey=#{Config.RONGCLOUD_APP_KEY}&nonce=844551300&timestamp=1467557868712&signature=13fe1fc1e9ee4f2fb6d8a671955858bc442d4f3d",
        channelType: 'PERSON'
        objectName: 'RC:TxtMsg'
        toUserId: Config.ROBOT_USER_ENCODED_ID
        content: 'hello world'
      , 200
      , null
      , done

    it 'Message content has not content key.', (done) ->
      this.testPOSTAPI "/receive?appKey=#{Config.RONGCLOUD_APP_KEY}&nonce=844551300&timestamp=1467557868712&signature=13fe1fc1e9ee4f2fb6d8a671955858bc442d4f3d",
        channelType: 'PERSON'
        objectName: 'RC:TxtMsg'
        toUserId: Config.ROBOT_USER_ENCODED_ID
        content: '{"name":"hello world"}'
      , 200
      , null
      , done

    it 'Not text message.', (done) ->
      this.testPOSTAPI "/receive?appKey=#{Config.RONGCLOUD_APP_KEY}&nonce=844551300&timestamp=1467557868712&signature=13fe1fc1e9ee4f2fb6d8a671955858bc442d4f3d",
        channelType: 'PERSON'
        objectName: 'RC:ImgMsg'
        toUserId: Config.ROBOT_USER_ENCODED_ID
        content: '{"content":"hello world"}'
      , 200
      , null
      , done

    it 'Invalid appKey.', (done) ->
      this.testPOSTAPI "/receive?appKey=sdf98sd98sfd&nonce=844551300&timestamp=1467557868712&signature=13fe1fc1e9ee4f2fb6d8a671955858bc442d4f3d",
        channelType: 'PERSON'
        objectName: 'RC:ImgMsg'
        toUserId: Config.ROBOT_USER_ENCODED_ID
        content: '{"content":"hello world"}'
      , 400
      , null
      , done

    it 'Invalid invoke.', (done) ->
      this.testPOSTAPI "/receive?appKey=#{Config.RONGCLOUD_APP_KEY}&nonce=844551300&timestamp=1467557868712&signature=42638938adcf35f7a00db1a20e461c35521d5ca8",
        channelType: 'PERSON'
        objectName: 'RC:TxtMsg'
        toUserId: Config.ROBOT_USER_ENCODED_ID
        content: '{"content":"hello world"}'
      , 400
      , null
      , done

  describe 'Test sending message.', ->

    it 'Correct.', (done) ->
      this.testPOSTAPI '/send',
        phone: '13921585267'
        content: 'hello world'
      , 200
      , 'OK'
      , done

    it 'Phone is empty.', (done) ->
      this.testPOSTAPI '/send',
        phone: null
        content: 'hello world'
      , 400
      , null
      , done

    it 'Content is empty.', (done) ->
      this.testPOSTAPI '/send',
        phone: '13921585267'
        content: null
      , 400
      , null
      , done

    it 'Phone is not in database.', (done) ->
      this.testPOSTAPI '/send',
        phone: '13912345678'
        content: 'hello world'
      , 404
      , null
      , done
