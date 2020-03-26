net = require 'net'

OFFSET =
    requestType: 0
    bodyLength : 4
    callbackId : 8

HEADER_LENGTH = 12

composeHeader = (requestType, bodyLength, callbackId) ->
    header = new Buffer HEADER_LENGTH

    header.writeUInt32LE requestType, OFFSET.requestType
    header.writeUInt32LE bodyLength , OFFSET.bodyLength
    header.writeUInt32LE callbackId , OFFSET.callbackId

    header # composed

parseHeader = (data) ->
    requestType: data.readUInt32LE OFFSET.requestType
    bodyLength : data.readUInt32LE OFFSET.bodyLength
    callbackId : data.readUInt32LE OFFSET.callbackId

class TarantoolTransport

    # # constructors # #

    @connect = (port, host, callback) ->
        socket = net.connect port, host, -> callback socket
        new TarantoolTransport socket

    constructor: (@socket) ->

        @nextCallbackId = 0
        @callbacks = {}
        @responsesAwaiting = 0
        @remainder = null

        do @socket.unref
        do @socket.setNoDelay
        @socket.on 'data', (data) => @dataReceived data

    # # response processing # #

    dataReceived: (data) ->
        if @remainder?
            data = Buffer.concat [@remainder, data]
            @remainder = null

        loop
            # enough data to read header?
            if data.length < HEADER_LENGTH
                @remainder = data
                break

            header = parseHeader data
            responseLength = HEADER_LENGTH + header.bodyLength

            # enough data to read body?
            if data.length < responseLength
                @remainder = data
                break

            # process this response
            @processResponse header.callbackId, data.slice HEADER_LENGTH, responseLength
            # are we finished yet?
            break if data.length is responseLength

            # there is more data, loop repeats
            data = data.slice responseLength, data.length
        return

    processResponse: (callbackId, body) ->
        if @callbacks[callbackId]?
            @callbacks[callbackId] body
            delete @callbacks[callbackId]

            @responsesAwaiting--
            do @socket.unref if @responsesAwaiting is 0
        else
            throw new Error 'trying to call absent callback #' + callbackId
        return

    registerCallback: (callback) ->
        @responsesAwaiting++
        do @socket.ref if @responsesAwaiting is 1

        callbackId = @nextCallbackId
        @callbacks[callbackId] = callback

        if callbackId is 4294967295 # tarantool limitation
            @nextCallbackId = 0
        else
            @nextCallbackId++

        callbackId # registered

    request: (type, body, callback) ->
        header = composeHeader type, body.length, @registerCallback callback
        @socket.write header
        @socket.write body
        return


    module.exports = TarantoolTransport
