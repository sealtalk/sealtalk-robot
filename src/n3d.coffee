class N3D
  constructor: (key, @lower, @upper) ->
    charMap = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split ''
    @radix   = charMap.length
    @dict    = []
    @keyCode = 0

    if not isUnsigned(@lower) or not isUnsigned(@upper)
      throw new Error 'Parameter is error.'

    if @upper <= @lower
      throw new Error 'The upper must be greater than the lower.'

    if typeof key isnt 'string' or key.length is 0
      throw new Error 'The key is error.'

    for i in [0...key.length]
      a = key.charCodeAt i
      if a > 127
        throw new Error 'The key is error.'

      @keyCode += a * Math.pow(128, i % 7)

    if @keyCode + @radix < @upper
      throw new Error 'The secret key is too short.'

    i = @keyCode - @radix
    j = 0
    while i < @keyCode
      @dict[j] = []

      k = @radix
      l = 0
      while k > 0
        s = i % k
        @dict[j][l] = charMap[s]
        charMap[s] = charMap[k - 1]
        k--
        l++

      charMap = @dict[j].slice(0)
      i++
      j++

  isUnsigned = (num) ->
    Math.floor(num) is num and num > 0 and num < Number.MAX_VALUE

  encrypt: (num) ->
    if not isUnsigned(num) or num > @upper or num < @lower
      throw new Error 'Parameter is error.'

    num = @keyCode - num
    result = []
    m = num % @radix
    map = @dict[m]
    s = 0

    result.push @dict[0][m]

    while num > @radix
      num = (num - m) / @radix
      m = num % @radix
      if (s = m + s) >= @radix
        s -= @radix

      result.push map[s]

    result.join ''

  decrypt: (str) ->
    if typeof str isnt 'string' and str.length is 0
      throw new Error 'Parameter is error.'

    chars = str.split ''
    len = chars.length
    t = 0
    s = 0
    result = @dict[0].join('').indexOf chars[0]

    if result < 0
      throw new Error 'Invalid string.'

    map = @dict[result].join ''

    for i in [1...len]
      j = map.indexOf chars[i]

      if j < 0
        throw new Error 'Invalid string.'

      if (s = j - t) < 0
        s += @radix

      result += s * Math.pow(@radix, i)
      t = j

    result = @keyCode - result

    if result > @upper or result < @lower
      throw new Error 'Invalid string.'

    result

module.exports = N3D
