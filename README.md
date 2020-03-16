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
