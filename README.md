# Transport-Tarantool-node



Transport incapsulates socket, manages callback, composes request headers, parses response headers, and composes response from several data packets.

**Use [Connector]()** as a high-level driver or create your own.

## NPM

```shell
npm install tarantool-transport
```
## API and usage
Call `Transport.connect port, host, callback` or `new Transport socket` to instantiate `transport`.
First way is common and preferrable while second allows to prepare `socket`, mock it or hack it.

Call `transport.request type, body, callback` to send request.

- `type` must be Number, any [valid request type](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L46): 0x0D, 0x11, 0x13, 0x15, 0x16 or 0xFF00.
- `body` must be Buffer (preferrable) or String (empty string is usable, see example below).
- `callback` will receive response body as Buffer, maybe empty, never `null` or `undefined`.

**All arguments are obligatory.**

### Examples

```coffee
Transport = require 'tarantool-transport'

PING = 0xFF00 # ping request type

transport = Transport.connect port, host, -> # on connection
    transport.request PING, '', -> # on response
        console.log 'got ping response'
    
    console.log 'sent ping request'
    
# the other way, if you want to prepare socket somehow
# net = require 'net'
# socket = net.connect port, host, ->
#     # on connection
# transport = new Transport socket
```

# Hacking

## Implementation notes

Before reading source please note that:
- In Tarantool, request and response headers are sequences of unsigned little-endian 32-bit integers.
- Tarantool allows to set `request_id`. Server will just white this value into `response`, it won't check or compare it with anything. In `transport` we call this field `callback_id` — we pass callbacks and one response calls means one callback here.

## Interaction with Socket

Constructed `transport` sets up `socket` in this way:
- `socket.unref()` to let `node.js` exit if we're not awaiting responses
- `socket.setNoDelay()` to reduce latency (added in 0.2.3)
- `socket.on('data', cb)` to parse and process responses

`transport` does `socket.ref()` on request and `socket.unref()` on last awaited response. Thus, `socket` prevents `node.js` from shutting down until it receives all responses.

This is the most common use case, but you can play with `socket` in any way, at your own risk.

## Inner variables

For those who want to hack Transport — list of inner variables:
- `socket` — `net` socket or Object you passed to constructor
- `remainder` — Buffer, will prepend next data chunk in order to compose responses from several data packets
- `callbacks` — Hash (Object), keys are numeric response ids, values are passed callbacks
- `nextCallbackId` — non-negative Number, incremented on request, when reaches 4294967296 overflows to 0, you can use it to describe request frequency
- `responsesAwaiting` — non-negative Number, incremented on request,decremented on response, stored to know when `ref()` and `unref()` the `socket`

## Bugs and issues
Bug reports and pull requests are welcome.
