(* 48 hours *)
let allowed_time_lapse = 172800

type storage = 
  {last_keep_alive : timestamp;
   subject : address;
   session_key : address;
   arbiters : address set;
   arbiter_approved_quit : bool}

type parameter =
  Quit | Approve_quit | Keep_alive | Add_arbiter of address
| Add_stake | Claim_stake | Set_session_key of address

type return = operation list * storage

let assert_subject_is_sender (storage : storage) : unit =
  let sender = Tezos.get_sender () in
  if sender = storage.subject || sender = storage.session_key
  then ()
  else failwith "whatchyu tryina pull son???"

let get_receiver (receiver : address) : unit contract = 
  match (Tezos.get_contract_opt receiver : unit contract option) with
  | Some contract -> contract
  | None -> (failwith "-_-" : unit contract) 

let main ((parameter, storage) : parameter * storage) : return =
  match parameter with
    Quit ->
      (let () = assert_subject_is_sender storage in
       let receiver = get_receiver storage.subject in
       let balance = Tezos.get_balance () in
       let op = Tezos.transaction () balance receiver in
       if storage.arbiter_approved_quit
       then ([op], storage)
       else
         let event1 =
           Tezos.emit "%here_ye_people_of_Tezos" () in
         let event2 =
           Tezos.emit
             "%subject_is_a_QUITTER"
             storage.subject in
         ([event1; event2; op], storage))
  | Approve_quit ->
      let sender = Tezos.get_sender () in
      if Set.mem sender storage.arbiters
      then
        let storage = {storage with arbiter_approved_quit = true; } in
        ([], storage)
      else failwith "I appreciate you, but no."
  | Keep_alive ->
      let () = assert_subject_is_sender storage in
      let storage = {storage with last_keep_alive =  Tezos.get_now () } in
      ([], storage)
  | Add_arbiter address ->
      let () = assert_subject_is_sender storage in
      let arbiters = Set.add address storage.arbiters in
      let storage = {storage with arbiters; } in
      ([], storage)
  | Set_session_key address ->
      let () = assert_subject_is_sender storage in
      let storage = {storage with session_key = address; } in
      ([], storage)
  | Add_stake -> ([], storage)
  | Claim_stake ->
      let kill_point =
        storage.last_keep_alive + allowed_time_lapse in
      if Tezos.get_now () > kill_point
      then
        let sender = Tezos.get_sender () in
        let receiver : unit contract = get_receiver sender in
        let balance = Tezos.get_balance () in
        let op = Tezos.transaction () balance receiver in
        ([op], storage)
      else
        failwith
          "SUBJECT IS LIVING THEIR BEST LIFE HOW DARE YOU"
