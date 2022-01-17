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
        | "Message Received" -> 
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
          (Printf.printf "The other side left the chat. \n\n";
          shutdown_connection ic; 
          raise Exit);
          let r = "Message Received"
          in output_string oc (r^"\n"); 
          flush oc;
          chat ic oc true)
  with 
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn
