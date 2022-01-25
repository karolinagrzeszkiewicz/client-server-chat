open UnixLabels

let t = ref 0.

let rec send_msg oc msg =
  output_string oc (msg^"\n");
  let new_msg = input_line Stdlib.stdin in
  begin match new_msg with
  | "" -> output_string oc (new_msg^"\n");
  | _ -> send_msg oc new_msg
  end

let rec read_msg ic acc =
  begin match input_line ic with
  | "" -> acc 
  | my_line -> read_msg ic (acc^my_line^"\n")
  end


let rec chat ic oc my_turn online = 
  begin match online with
  | true -> 
    if my_turn
    then 
      (print_string "Send: ";
      flush Stdlib.stdout; 
      output_string oc "msg: ";
      let msg = input_line Stdlib.stdin in
      send_msg oc msg;
      t := Unix.gettimeofday ();
      flush oc;
      chat ic oc false true)
    else 
      (let r = input_line ic 
      in begin match String.sub r 0 5 with
      | "msg: " -> 
        let msg = if (String.length r > 5) then read_msg ic ((String.sub r 5 ((String.length r)-5))^"\n") else read_msg ic ""
        in Printf.printf "Received: %s \n" msg;
        flush Stdlib.stdout;
        output_string oc ("ack: Message Received\n"); 
        flush oc;
        chat ic oc true true
      | "ack: " -> 
        print_endline "Message Received\n";
        Printf.printf "Roundtrip time: %fs\n\n" (Unix.gettimeofday () -. !t);
        flush Stdlib.stdout;
        chat ic oc false true
      | _ -> ()
      end)
  | false -> ()
  end


  let main_chat ic oc my_turn =
    try 
      chat ic oc my_turn true
    with
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn