request = require 'supertest'
app     = require '../../src'

beforeAll ->
  this.testPOSTAPI = (path, params, statusCode, testBody, callback) ->
    _this = this

    request app
      .post path
      .type 'form'
      .send params
      .end (err, res) ->
        _this.testHTTPResult err, res, statusCode, testBody
        callback res.body if callback

  this.testHTTPResult = (err, res, statusCode, testBody) ->
    if statusCode
      expect(res.status).toEqual(statusCode)

      # if res.status is 500
      #   console.log 'Server error: ', res.text
      #   console.log 'Respone status: ', res.status
      #   console.log 'Respone error: ', err
      # else if res.status isnt statusCode
      #   console.log 'Respone message: ', res.text
      #   console.log 'Respone status: ', res.status
      #   console.log 'Respone error: ', err
