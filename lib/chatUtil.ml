(* 
let copy_channels ic oc =
  try 
    while true do 
      let s = input_line ic 
      in if s = "END" then raise End_of_file 
      else (output_string oc (s^"\n"); flush oc)
    done
  with End_of_file -> ();;
*)
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

let client_turn = ref true

let receiver ic oc =
  try while true do 
        let s = input_line ic in
        Printf.printf "Received: %s \n\n" s;
        flush Stdlib.stdout;
        (*let r = s*)
        (*let r = (input_line Stdlib.stdin)^"\n"*)
        let r = "message received"
        in output_string oc (r^"\n"); flush oc 
      done
  with _ -> Printf.printf "End of text\n"; flush Stdlib.stdout; exit 0;;

let sender ic oc =
  try 
    while true do 
      print_string "Send: ";
      flush Stdlib.stdout;
      output_string oc ((input_line Stdlib.stdin)^"\n");
      t := Unix.gettimeofday ();
      flush oc;
      let r = input_line ic 
      in Printf.printf "Received: %s \n\n" r;
      flush Stdlib.stdout;
      Printf.printf "Roundtrip time: %fs\n" (Unix.gettimeofday () -. !t);
      flush Stdlib.stdout;
      (* if r = "END" then (shutdown_connection ic; raise Exit);*)
    done 
  with 
    Exit -> exit 0
    | exn -> shutdown_connection ic; raise exn;;


  let receive ic oc = 
    let s = input_line ic in
    Printf.printf "Received: %s \n\n" s;
    flush Stdlib.stdout;
    (*let r = s*)
    (*let r = (input_line Stdlib.stdin)^"\n"*)
    let r = "message received"
    in output_string oc (r^"\n"); flush oc 

  let send ic oc =
    print_string "Send: ";
    flush Stdlib.stdout;
    output_string oc ((input_line Stdlib.stdin)^"\n");
    t := Unix.gettimeofday ();
    flush oc;
    let r = input_line ic 
    in Printf.printf "Received: %s \n\n" r;
    flush Stdlib.stdout;
    Printf.printf "Roundtrip time: %fs\n" (Unix.gettimeofday () -. !t);
    flush Stdlib.stdout;
    if r = "END" then (shutdown_connection ic; raise Exit);
    ();;
  

  (*let chat ic oc my_turn =
    (*let my_turn = ref is_my_turn in*)
    try 
      while true do 
        while (not !my_turn) do
          ()
        done;
        match Unix.fork() with 
        | 0 -> 
          send ic oc;
          let _ = exit 0
          in ()
        | id -> 
          receive ic oc; 
          let _ = exit id
          in ();
        my_turn := not !my_turn
      done
    with 
      | Exit -> exit 0
      | exn -> shutdown_connection ic; raise exn
      (*| _ -> Printf.printf "End of text\n"; flush Stdlib.stdout; exit 0;;*)
  *)

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



      








(*
let t = ref 0.

let receiver ic oc =
  try 
    while true do 
      let r = input_line ic in 
      Printf.printf "Received: %s \n" r;
      flush oc;
      flush Stdlib.stdout;
      output_string oc ("message received");
      flush oc;
      print_endline "sent ack";
      flush Stdlib.stdout;
      (*in Printf.printf "Received: %s \n" r;
      if r = "END" then 
        (shutdown_connection ic; 
        (*output_string oc "EXIT";
        flush oc;*)
        raise Exit)
      else 
        (flush Stdlib.stdout;
        flush oc;
        output_string oc "message received"; (* should pass this to the sender of the received message *)
        print_endline "sent acknowledgement!";
        (*flush oc*));*)
    done 
  with 
    | Exit -> exit 0 
    | exn -> shutdown_connection ic; raise exn;;

let sender ic oc = 
  (*let rec wait () = 
    try 
      let r = input_line ic in (* does it wait for input line ? *)
      print_endline r;
      match r with 
      | "message received" -> 
        print_endline r; (* ? *)
        flush Stdlib.stdout;
        flush oc;
        Printf.printf "Roundtrip time: %fs\n" (Unix.gettimeofday () -. !t)
        (*output_string oc r;
        flush oc*)
      | "EXIT" -> shutdown_connection ic; raise Exit
      | _ -> Printf.printf "sender got an unexpected message: %s" r
    with 
      | _ -> print_endline "eh"; wait ()
  in*) try 
    while true do 
      (* send message *)
      t := Unix.gettimeofday ();
      print_string "Send: ";
      flush Stdlib.stdout;
      output_string oc ((input_line Stdlib.stdin)^"\n");
      flush oc (* ? *);
      print_endline "finished writing";
      flush Stdlib.stdout;
      (* wait for acknowledgement *)
      let r = input_line ic in
      Printf.printf "Response: %s \n \n " r;
      flush Stdlib.stdout;
      if r = "END" then (shutdown_connection ic; raise Exit)
      (*wait ()*)
    done 
  with 
  | Exit -> exit 0 
  | exn -> shutdown_connection ic; raise exn
*)