
(* 
receiver
1. prints the received message
2. sends "message received"  
*)

(*
sender
1. receives and prints "message received" 
2. calculates and prints roundtrip time
3. sends another message
*)

open UnixLabels

let t = ref 0.

let client_awaiting_ack = ref false
let server_awaiting_ack = ref false
let awaiting_ack = ref false
let confirmed = ref true
let online = ref true



let rec sender ic oc sent t _ = 
  try 
    if (not sent)
    then 
      (print_string "Send: ";
      flush Stdlib.stdout;
      output_string oc ((input_line Stdlib.stdin)^"\n\n");
      let t_curr = Unix.gettimeofday () in
      flush oc;
      sender ic oc true t_curr ())
    else 
      (let r = input_line ic in 
      if r = "Message Received"
      then 
        (Printf.printf "%s \n\n" r;
        flush Stdlib.stdout;
        Printf.printf "Roundtrip time: %fs\n\n" (Unix.gettimeofday () -. t);
        flush Stdlib.stdout;
        sender ic oc false 0.0 ()))
  with 
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn

let rec receiver ic oc _ = 
  try 
    let msg = input_line ic in 
    if msg != "Message Received"
    then 
      (Printf.printf "Received: %s \n\n" msg;
      flush Stdlib.stdout;
      if msg = "end" 
      then 
        (Printf.printf "Client left the chat. \n\n";
        shutdown_connection ic; 
        raise Exit);
      let r = "Message Received"
      in output_string oc (r^"\n"); 
      flush oc;
      receiver ic oc ())
    with 
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn

let sender2 ic oc _ = 
  try 
    while true do 
      if (!confirmed)
      then 
        (print_string "Send: ";
        flush Stdlib.stdout;
        output_string oc ((input_line Stdlib.stdin)^"\n\n");
        t := Unix.gettimeofday ();
        flush oc;
        confirmed := false)
    done;
    Thread.exit();
    online := false;     
  with 
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn
    
let receiver2 ic oc _ = 
  try 
   while true do 
    let r = input_line ic 
    in match r with 
      | "Message Received" -> 
        Printf.printf "%s \n\n" r;
        flush Stdlib.stdout;
        Printf.printf "Roundtrip time: %fs\n\n" (Unix.gettimeofday () -. !t);
        flush Stdlib.stdout;
        confirmed := true
      | msg -> 
        Printf.printf "Received: %s \n\n" msg;
        flush Stdlib.stdout;
        if r = "end" 
        then 
        (Printf.printf "The other side left the chat. \n\n";
        shutdown_connection ic; 
        raise Exit);
        let r = "Message Received"
        in output_string oc (r^"\n"); 
        flush oc;
    done
  with 
    Exit -> exit 0
    | exn -> Thread.exit(); online := false; shutdown_connection ic; raise exn
      

let chat2 ic oc = 
  let t1 = Thread.create (sender2 ic oc) () in
  let t2 = Thread.create (receiver2 ic oc) () in
  while !online do Thread.delay(0.2) done;
  Thread.join t1;
  Thread.join t2


let rec chat ic oc my_turn = 
  try 
    if my_turn
    then 
      (print_string "Send: ";
      flush Stdlib.stdout;
      output_string oc ((input_line Stdlib.stdin)^"\n\n");
      t := Unix.gettimeofday ();
      flush oc;
      chat ic oc false;
      ())
    else 
      (let r = input_line ic 
      in match r with 
        | "Message Received" -> 
          Printf.printf "%s \n\n" r;
          flush Stdlib.stdout;
          Printf.printf "Roundtrip time: %fs\n\n" (Unix.gettimeofday () -. !t);
          flush Stdlib.stdout;
          chat ic oc false 
        | msg -> 
          Printf.printf "Received: %s \n\n" msg;
          flush Stdlib.stdout;
          if r = "end" 
          then 
          (Printf.printf "Client left the chat. \n\n";
          shutdown_connection ic; 
          raise Exit);
          let r = "Message Received"
          in output_string oc (r^"\n"); 
          flush oc;
          chat ic oc true)
  with 
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn;;
