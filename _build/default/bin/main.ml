open Unix
open ChatUtil

let get_my_inet_addr () =
  let my_name = Unix.gethostname() 
  in let my_entry_by_name = gethostbyname my_name
  in my_entry_by_name.Unix.h_addr_list.(0);;

let get_inet_addr socket_addr =
  match socket_addr with
  | Unix.ADDR_INET (addr, _) -> Unix.string_of_inet_addr addr
  | _ -> failwith "not INET"

let get_port socket_addr =
  match socket_addr with
  | Unix.ADDR_INET (_, port) -> port 
  | _ -> failwith "not INET"


(* default values *)
let is_server = ref true
let server_port = ref 1234
let server_ip = ref "127.0.0.1"
let server_address = get_my_inet_addr ()

(* parse command line arguments *)

let set_args () =
  match Sys.argv.(1) with
  | "client" -> 
    is_server := false;
    Printf.printf "launching client mode\n"
  | "server" -> Printf.printf "launching server mode\n"
  | _ -> Printf.printf "incorrect input : must be either server or client, launching server mode\n";
  if Array.length Sys.argv > 2
  then 
    (server_ip :=  Sys.argv.(2);
    Printf.printf "for server with IP address: %s \n" !server_ip);
  if Array.length Sys.argv > 3
  then 
    (server_port := int_of_string Sys.argv.(3);
    Printf.printf "and with port number: %d \n" !server_port)


let parse_args () =
  match Array.length Sys.argv with
  | 0 | 1 -> 
    Printf.printf "arguments missing: launching server mode and using default server port number: %d, and host address: %s \n \n" !server_port !server_ip
  | 2 -> 
    set_args();
    Printf.printf "arguments missing: using default server port number: %d, and host address: %s \n \n" !server_port !server_ip
  | 3 ->
    set_args();
    Printf.printf "arguments missing: using default server host address: %s \n \n" !server_ip
  | _ -> set_args()

  (* guarantees that in case client launches without specifying port number and ip address 
    and the server is already launched, it will use the launched server's port and ip address by default *)

  (* TODO: what if client launches before the server? *)

(* SERVER *)

let run_server server_addr = 
  let server_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in 
  Unix.bind server_descr server_addr;
  Unix.listen server_descr 1; (* waiting for 1 client only *)
  print_endline "The server is waiting for client to connect. \n";
  while true do (* can handle multiple connections sequentially *)
    let (client_descr, client_addr) = Unix.accept server_descr in
    Printf.printf "Connected to client: %s: %d \n" (get_inet_addr client_addr) (get_port client_addr);
    let pid = Unix.fork() (* create child process to handle requests *)
    in match pid with
    | 0 -> (* child code *)
      let ic = Unix.in_channel_of_descr client_descr 
      and oc = Unix.out_channel_of_descr client_descr in
      chat ic oc false;
      Printf.printf "Client left the chat. \n";
      close_in ic;
      close_out oc;
      exit 0
    | id ->  (* parent code *)
      Unix.close client_descr;
      ignore(Unix.waitpid [] id)
  done

  (* TODO: 
  after connection is terminated by the client server continues waiting for 
  another client
  *)

  (* TODO: server_func
    upon receiving a message msg:
    1. acknowledge the message by sending back "message received"
    2. show the roundtrip time for acknowledgement
    3. reply 

    e.g. the terminal output should be sth like:
    client sent: hello
    sent to client: Message Received
    reply: hi
    Roundtrip time: 0.04 s


  *)

(* CLIENT *)

(* command-line arguments: IP address / hostname of server*)


let run_client server_addr  =
  try
    Printf.printf "Trying to connect to server: %s: %d \n" 
    (get_inet_addr server_addr) (get_port server_addr);
    (*Printf.printf "Trying to connect as client: %s: %d to server: %s: %d \n" 
    (get_inet_addr (Unix.getsockname client_descr)) (get_port (Unix.getsockname client_descr)) 
    (get_inet_addr server_addr) (get_port server_addr);*)
    (*Unix.connect client_descr server_addr;*) 
    let ic, oc = open_connection server_addr in
    print_endline "Connected! \n";
    (* call client_func *)
    chat ic oc true;
    shutdown_connection ic
  with _ -> print_endline "The chat has ended. \n"


  let () =
    parse_args ();
    (*let server_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in *)
    let server_addr = Unix.ADDR_INET (Unix.inet_addr_of_string !server_ip, !server_port) in 
    (*let client_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in*)
    if (!is_server)
    then Unix.handle_unix_error run_server server_addr
    else Unix.handle_unix_error run_client server_addr



