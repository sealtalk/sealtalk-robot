Utility = require '../src/util'
App = require '../src/index'

describe 'Test functions', ->
  describe 'Test send message method.', ->
    it 'Success.', (done) ->
      Utility.sendMessage 'fromUserId', 'toUserId', 'hello world', (success, resultText) ->
        expect(success).toEqual(true)
        done()

    it 'Invalid patameter.', (done) ->
      Utility.sendMessage 'fromUserId', ['toUserId'], 'hello world', (success, resultText) ->
        expect(success).toEqual(false)
        done()

  describe 'Test invoket Tuling method.', ->
    it 'Success.', (done) ->
      App.invokeTuling 'testUserId', '你好'
      .then (content) ->
        expect(content.length).toBeGreaterThan(0)
        expect(typeof content).toEqual('string')
        done()
