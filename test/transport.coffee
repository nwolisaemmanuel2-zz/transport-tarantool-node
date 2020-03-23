Transport = require '../src'
PING = 65280

exports['connect'] = (test) ->
    test.expect 1
    test.doesNotThrow ->
      

exports['partial responses'] = (test) ->
    test.expect 2
    
    mySocket =
        written: 0
        ref: ->
        unref: ->
        write: (buffer) ->
            @written += buffer.length
            
        on: (event, listener) ->
            @writeBack = listener
            
    
    transport = new Transport mySocket
    
    transport.request PING, '', (response) ->
    transport.request PING, '', (response) ->
        test.done()
    
    firstChunk = new Buffer [0, 255, 0, 0, 0, 0] # 6
    secondChunk = new Buffer [0, 0, 0, 0, 0, 0, 0, 255] # 8
    thirdChunk = new Buffer [0, 0, 0, 0, 0, 0, 1, 0, 0, 0] # 10
      mySocket.writeBack firstChunk
        test.equal transport.remainder, firstChunk
    mySocket.writeBack secondChunk
    test.equal transport.remainder.toString(), new Buffer([0, 255]).toString()
    
    mySocket.writeBack thirdChunk
    
    
  
    
    
