
(*
 * areWeClose.ml - solution to the Shoreline Software social net problem
 * doug makofka - doug@makofka.org
 * github.com/onokognome/areWeClose
 *
 *)





type user_friends = { id : int; friends : int list }

let user_hshtbl = Hashtbl.create 100  (* this is a hash from int (user.id) to user_friends *)


(* next_depth : int list -> user_friends list
 *
 * this function takes a list of user_friends and returns a list of the friends of each user
 * minus any friends that have already been marked as 'evaluated'. This could have been
 * written to do only one iteration over the user list, but is easier to understand as
 * written.
 *
 *)

let next_depth marked_lst user_lst =
  try
     let unmarked = List.fold_left (fun acc user ->
     List.fold_left (fun acc user_id -> Hashtbl.find user_hshtbl user_id :: acc) acc user.friends)
       [] user_lst
     in List.fold_left (fun acc user -> if List.mem user.id marked_lst then acc else user :: acc)
      [] unmarked
  with _ -> (print_endline ("user in chain not found"); exit 2)


(*
 * process_one_user : int -> (int list, int, bool) -> user_friend -> (int list, int, bool)
 *
 * this function is called curried in the first argument from a 'fold_left'
 * it updates the state accumulator (marked_lst, depth, is_found) based on its processing
 * of a single user.
 *
 *)

let process_one_user user_id_b (marked_lst, depth, is_found) user =
    if is_found then
      (marked_lst, depth, is_found)
    else begin			      
      if List.mem user.id marked_lst
      then
        (marked_lst, depth, is_found)
      else begin
        if List.mem user_id_b user.friends  
      then
        (marked_lst, depth, true)
      else 
        (user.id :: marked_lst, depth, is_found)
    end end

(*
 * search_chain : user_friends list -> int -> int 
 *
 * this function takes an intial list of user_friends (but probably only one) and the user id
 * of the friendship target, and returns the chain length between them. 0 means there is no
 * chain of friends between the two.
 *
 *)
let search_chain user_lst user_id_b =
  let rec process_chain (marked_lst, depth, is_found) user_lst =
    let (marked_lst, depth, is_found) =
      List.fold_left (process_one_user user_id_b) (marked_lst, depth, is_found) user_lst in
    if is_found then (marked_lst, depth, is_found)  (* we're done*)
    else
      match next_depth marked_lst user_lst with
      | [] -> (marked_lst, depth, is_found)   (* every user in the chain has been marked *)
      | _ -> process_chain (marked_lst, depth+1, is_found) (next_depth marked_lst user_lst)
  in
   match process_chain ([], 1, false) user_lst with
   | (_, depth, true) -> depth
   | _ -> 0
    
(* chain_length : int -> int -> int
 *
 * chain_length takes 2 user id's and returns the length of the chain between them.
 * 0 means no friend chain exists. 1 means they are friends.
 *)
let chain_length user_a_id user_b_id =
  let user_a = try Hashtbl.find user_hshtbl user_a_id
  with  _ -> (print_endline ("user:"^(string_of_int user_a_id)^" not found");
       exit 1 )
  in 
  if (Hashtbl.mem user_hshtbl user_b_id) then
    search_chain [user_a] user_b_id
  else begin
    print_endline ("user:"^(string_of_int user_b_id)^" not found");
    exit 1
    end

    
let _ =
Hashtbl.add user_hshtbl 1 {id = 1; friends = [3; 5]};
Hashtbl.add user_hshtbl 2 {id = 2; friends = [8]};
Hashtbl.add user_hshtbl 3 {id = 3; friends = [1;7]};
Hashtbl.add user_hshtbl 4 {id = 4; friends = [9]};
Hashtbl.add user_hshtbl 5 {id = 5; friends = [1]};
Hashtbl.add user_hshtbl 6 {id = 6; friends = [7]};
Hashtbl.add user_hshtbl 7 {id = 7; friends = [3;6;8]};
Hashtbl.add user_hshtbl 8 {id = 8; friends = [7;2]};
Hashtbl.add user_hshtbl 9 {id = 9; friends = [4]};
match chain_length 1 1   with
| 0 -> print_endline "no chain of friends"
| n -> print_endline ("friend chain length is "^(string_of_int n));

