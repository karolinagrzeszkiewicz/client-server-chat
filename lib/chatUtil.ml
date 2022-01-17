
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

let rec chat ic oc my_turn = 
  try 
    if my_turn
    then 
      (print_string "Send: ";
      flush Stdlib.stdout;
      output_string oc ((input_line Stdlib.stdin)^"\n");
      t := Unix.gettimeofday ();
      flush oc;
      chat ic oc false;
      ())
    else 
      (let r = input_line ic 
      in match r with 
        | "message received" -> 
          Printf.printf "%s \n\n" r;
          flush Stdlib.stdout;
          Printf.printf "Roundtrip time: %fs\n" (Unix.gettimeofday () -. !t);
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
          let r = "message received"
          in output_string oc (r^"\n"); 
          flush oc;
          chat ic oc true)
  with 
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn;;
