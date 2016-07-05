Utility = require '../src/util'

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
