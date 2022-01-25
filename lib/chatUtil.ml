open UnixLabels

let t = ref 0.


let rec chat ic oc my_turn online = 
  begin match online with
  | true -> 
    if my_turn
    then 
      (print_string "Send: ";
      flush Stdlib.stdout;
      output_string oc ((input_line Stdlib.stdin)^"\n");
      t := Unix.gettimeofday ();
      flush oc;
      chat ic oc false true)
    else 
      (let r = input_line ic 
      in Printf.printf "Received: %s \n\n" r;
      flush Stdlib.stdout;
      if r = "Message Received"
      then (Printf.printf "Roundtrip time: %fs\n" (Unix.gettimeofday () -. !t);
      flush Stdlib.stdout;
      chat ic oc false true)
      else 
      (let r = "Message Received"
      in output_string oc (r^"\n"); 
      flush oc;
      chat ic oc true true))
      (* 
          Printf.printf "Roundtrip time: %fs\n" (Unix.gettimeofday () -. !t);
          flush Stdlib.stdout;
          chat ic oc false 
      *)
          (*if r = "end" 
          then 
          (Printf.printf "The other side left the chat. \n\n";
          shutdown_connection ic; 
          raise Exit);*)
  | false -> ()
  end


  let main_chat ic oc my_turn =
    try 
      chat ic oc my_turn true
    with
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn