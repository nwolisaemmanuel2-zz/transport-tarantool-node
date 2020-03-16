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
