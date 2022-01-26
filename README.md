## Building a Client-Server Chat Service in Ocaml

This is project contains a simple application which allows a client and server to chat from two different windows of a linux terminal. 

### How to run the application?

In order to launch the server open the terminal and from the root of this repository type:

```
make
./bin/client_server_chat server
```
this is going to launch a server with the default IP address 127.0.0.1 and default port number 1234. In order to customize the IP address and port number type:
```
./bin/client_server_chat server <IP address> <port number>
```
instead.

Similarly, to launch a client connecting to a server with given IP address and port number open a new terminal window and from the root of the repository type:
```
./bin/client_server_chat client <IP address> <port number>
```
where failure to provide the above-mentioned parameters will result in the client connecting to the server that is currently online.

### Example:

The server side:
```
./bin/client_server_chat server
Launching server mode... 

for server with IP address: 127.0.0.1 

and with port number: 5530 

The server is waiting for client to connect. 

Connected to client: 127.0.0.1: 49679 

Received: hi
 
Send: hello

Message Received

Roundtrip time: 0.000332s

Received: how to send messages?
to go to the next line press RET
then you can type messages that are arbitrarily many lines long
and to finally send the message press RET two times
 
Send: okay, can you send empty messages? like newline on its own?

Message Received

Roundtrip time: 0.000324s

Received: 
 
Send: and can you send 'Message Received'?

Message Received

Roundtrip time: 0.000352s

Received: Message Received
 
Send: got it, and how do you leave the chat?

Message Received

Roundtrip time: 0.000331s

Received: by pressing CTRL c
 
Send: can you leave now?

Message Received

Roundtrip time: 0.000258s

The chat has ended.
Connected to client: 127.0.0.1: 49682 

Received: hi, I left and re-entered the chat
 
Send: hi again

Message Received

Roundtrip time: 0.000309s

Received: try sending a very long message
 
Send: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa                                        

Message Received

Roundtrip time: 0.000475s

Received: and now leave the chat?
 
Send: ^C
```


The client side:
```
./bin/client_server_chat client 127.0.0.1 5530

Launching client mode... 

for server with IP address: 127.0.0.1 

and with port number: 5530 

Trying to connect to server: 127.0.0.1: 5530 

The requested server is offline/The chat has ended. 


./bin/client_server_chat client 127.0.0.1 5530

Launching client mode... 

for server with IP address: 127.0.0.1 

and with port number: 5530 

Trying to connect to server: 127.0.0.1: 5530 

Connected! 


Send: hi

Message Received

Roundtrip time: 0.000342s

Received: hello
 
Send: how to send messages?
to go to the next line press RET
then you can type messages that are arbitrarily many lines long
and to finally send the message press RET two times

Message Received

Roundtrip time: 0.000415s

Received: okay, can you send empty messages? like newline on its own?
 
Send: 

Message Received

Roundtrip time: 0.000269s

Received: and can you send 'Message Received'?
 
Send: Message Received

Message Received

Roundtrip time: 0.000313s

Received: got it, and how do you leave the chat?
 
Send: by pressing CTRL c

Message Received

Roundtrip time: 0.000243s

Received: can you leave now?
 
Send: ^C
karolinagrzeszkiewicz@Karolinas-MacBook-Pro client-server-chat % ./bin/client_server_chat client 127.0.0.1 5530
Launching client mode... 

for server with IP address: 127.0.0.1 

and with port number: 5530 

Trying to connect to server: 127.0.0.1: 5530 

Connected! 


Send: hi, I left and re-entered the chat

Message Received

Roundtrip time: 0.000377s

Received: hi again
 
Send: try sending a very long message

Message Received

Roundtrip time: 0.000261s

Received: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
 
Send: and now leave the chat?

Message Received

Roundtrip time: 0.000290s

The requested server is offline/The chat has ended. 
```


This time the server decided to leave the chat and go offline.

### Discussion

In order to keep the server running while different clients enter and leave the server is split into processes: 1. a single parent process which 'keeps the server running' terminating connections, waiting for new connections etc. 2. child processes, with a new child process being launched every time the server connects to a new client in order to handle the chat with that client, and then terminated once the client leaves the chat.

The client and the server use a single chat function which takes as input an output channel and an input channel through which the two processes can communicate as well as a boolean indicating whether it is the client's or the server's turn to message the other. Thus the chat is like a ping pong match where only one player at a time gets to hit a ball and then passes it to the other one. I chose this sequential design because of its simplicity – the client and the server simply switch the 'sender' and 'receiver' roles with each other. After trying to design a concurrent chat where the client and the server can message each other anytime as each employs a sender and receiver thread to handle both roles concurrently I realised that even though such design allows the messages to be exchanged freely it is difficult to reconcile this freedom with a comprehensible terminal output. Yet this is a challenge I would be happy to take up in the future!

Another challenge would be to design a server that could chat with multiple clients concurrently. I imagine this could be done by assigning one child unix process to each new client. Yet again this entails the challenge of designing a good user interface for the server chatting with multiple clients at the same time.





