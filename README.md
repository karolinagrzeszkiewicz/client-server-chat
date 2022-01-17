## Building a Client-Server Chat Service in Ocaml

This is project contains a simple application which allows a client and server to chat from two different windows of a linux terminal. 

### How to run the application?

In order to launch the server open the terminal and from the root of this repository type:

```
dune clean
dune build
dune exec -- client_server_chat server
```
this is going to launch a server with the defulat IP address 127.0.0.1 and default port number 1234. In order to customize the IP address and port number type:
```
dune exec -- client_server_chat server <IP address> <port number>
```
instead.

Similarly, to launch a client connecting to a server with given IP address and port number open a new terminal window and from the root of the repository type:
```
dune exec -- client_server_chat client <IP address> <port number>
```
where failure to provide the above-mentioned parameters will result in the client connecting to the server that is currently online.

### Example:

The server side:
```
dune exec -- client_server_chat server
Launching server mode... 

Arguments missing: using default server port number: 1234, and host address: 127.0.0.1 
 
The server is waiting for client to connect. 

Connected to client: 127.0.0.1: 53167 

Received: hi 

Send: hello
Message Received 

Roundtrip time: 0.000325s
Received: how's life 

Send: good good
Message Received 

Roundtrip time: 0.000282s
Received: end 

The other side left the chat. 
```

The client side:
```
dune exec -- client_server_chat client
Launching client mode... 

Arguments missing: using default server port number: 1234, and host address: 127.0.0.1 
 
Trying to connect to server: 127.0.0.1: 1234 

Connected! 


Send: hi
Message Received 

Roundtrip time: 0.000302s
Received: hello 

Send: how's life
Message Received 

Roundtrip time: 0.000255s
Received: good good 

Send: end
The requested server is offline/The chat has ended. 
```

As we can see the client has ended the chat. Yet the server is still online waiting for another client to connect:

The server side:
```
Connected to client: 127.0.0.1: 53168 

Received: hello again 

Send: end
The chat has ended.
```

The client side:
```
dune exec -- client_server_chat client
Launching client mode... 

Arguments missing: using default server port number: 1234, and host address: 127.0.0.1 
 
Trying to connect to server: 127.0.0.1: 1234 

Connected! 


Send: hello again
Message Received 

Roundtrip time: 0.000261s
Received: end 

The other side left the chat.
```

This time the server decided to leave the chat and go offline.

### Discussion

In order to keep the server running while different clients enter and leave the server is split into processes: 1. a single parent process which 'keeps the server running' terminating connections, waiting for new connections etc. 2. child processes, with a new child process being launched every time the server connects to a new client in order to handle the chat with that client, and then terminated once the client leaves the chat.

The client and the server use a single chat function which takes as input an output channel and an input channel through which the two processes can communicate as well as a boolean indicating whether it is the client's or the server's turn to message the other. Thus the chat is like a ping pong match where only one player at a time gets to hit a ball and then passes it to the other one. I chose this sequential design because of its simplicity – the client and the server simply switch the 'sender' and 'receiver' roles with each other. After trying to design a concurrent chat where the client and the server can message each other anytime as each employs a sender and receiver thread to handle both roles concurrently I realised that even though such design allows the messages to be exchanged freely it is difficult to reconcile this freedom with a comprehensible terminal output. Yet this is a challenge I would be happy to take up in the future!

Another challenge would be to design a server that could chat with multiple clients concurrently. I imagine this could be done by assigning one child unix process to each new client. Yet again this entails the challenge of designing a good user interface for the server chatting with multiple clients at the same time.





