# transport-tarantool-node

Transport incapsulates socket, manages callbacks, composes request headers, parses response headers, and composes response from several data packets.

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

### Example

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
