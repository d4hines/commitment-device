#import "../src/contract.mligo" "Contract"
#import "../breathalyzer/lib/lib.mligo" "Breath"
#import "../breathalyzer/examples/auction/src/auction_sc.mligo" "Auction"
#import "./util.mligo" "Util"

let approved_quit =
  Breath.Model.case
    "quit"
    "approve quit, quit => subject gets money back"
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, carol)) = Breath.Context.init_default () in
       let max_round_trip_burn = 3tez in
       let alice_balance = Test.get_balance alice.address in
       let expected_alice_balance = 
         Option.unopt (alice_balance - max_round_trip_burn) in
       let stake_amount = 100tez in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address; carol.address]
           None
           stake_amount
           in
       let bob_action =
         Breath.Context.act_as
           bob
           (Util.call
              contract
              Approve_quit
              0mutez) in   
       let alice_action =
         Breath.Context.act_as
           alice
           (Util.call
              contract
              Quit
              0mutez) in
       Breath.Result.reduce
       [
          bob_action;
          Util.assert_state contract (fun (storage : Contract.storage) -> storage.arbiter_approved_quit);
          alice_action;
          (Util.assert_balance_is_at_least alice expected_alice_balance)
          ])

let unapproved_quit =
  Breath.Model.case
    "quit"
    "unapprove quit, quit => subject gets still money back"
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, carol)) = Breath.Context.init_default () in
       let round_trip_burn = 3tez in
       let alice_balance = Test.get_balance alice.address in
       let expected_alice_balance = 
         Option.unopt (alice_balance - round_trip_burn) in
       let stake_amount = 100tez in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address; carol.address]
           None
           stake_amount
           in
       let alice_action =
         Breath.Context.act_as
           alice
           (Util.call
              contract
              Quit
              0mutez) in
       Breath.Result.reduce
       [
          alice_action;
          (Util.assert_balance_is_at_least alice expected_alice_balance)
          ])
        
let impersonating_quit =
  Breath.Model.case
    "quit"
    "impersonating quit => error"
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, carol)) = Breath.Context.init_default () in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address; carol.address]
           None
           100tez
           in
       let bob_action =
         Breath.Context.act_as
           bob
           (Util.call
              contract
              Quit
              0mutez) in
       Breath.Result.reduce
       [ Breath.Expect.fail_with_message "whatchyu tryina pull son???" bob_action; ])

let keep_alive =
  Breath.Model.case
    "keep_alive"
    "keep alive resets the clock"
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, carol)) = Breath.Context.init_default () in
       let some_date : timestamp = ("2000-01-01t10:10:10Z" : timestamp) in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address; carol.address]
           (Some some_date)
           100tez
           in
       let alice_action =
         Breath.Context.act_as
           alice
           (Util.call
              contract
              Keep_alive
              0mutez) in
       Breath.Result.reduce
          [alice_action; (Util.assert_state contract (fun storage -> storage.last_keep_alive = Tezos.get_now ()))])

let add_arbiter =
  Breath.Model.case
    "add_arbiter"
    "adding an aribter works"
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, carol)) = Breath.Context.init_default () in
       let some_date : timestamp = ("2000-01-01t10:10:10Z" : timestamp) in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address;]
           (Some some_date)
           100tez
           in
       let alice_action =
         Breath.Context.act_as
           alice
           (Util.call
              contract
              (Add_arbiter carol.address)
              0mutez) in
       Breath.Result.reduce
          [alice_action; (Util.assert_state contract (fun storage -> Set.mem carol.address storage.arbiters))])

let add_stake =
  Breath.Model.case
    "add_stake"
    "adding stake works"
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, _carol)) = Breath.Context.init_default () in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address;]
           None
           100tez
           in
       let alice_action =
         Breath.Context.act_as
           alice
           (Util.call
              contract
              Add_stake
              100tez) in
       Breath.Result.reduce
          [alice_action; (Util.assert_balance contract 200tez)])

let valid_claim =
  Breath.Model.case
    "claim"
    "valid claims are accepted"
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, _carol)) = Breath.Context.init_default () in
       let some_date : timestamp = ("1969-01-01T00:00:30Z" : timestamp) in
       let stake = 100tez in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address;]
           (Some some_date)
           stake
           in
       let bob_balance = Test.get_balance bob.address in
       let max_fees = 3tez in
       let expected_bob_balance = Option.unopt (bob_balance + stake - max_fees) in
       let bob_action =
         Breath.Context.act_as
           bob
           (Util.call
              contract
              Claim_stake
              0tez) in
       Breath.Result.reduce
          [ bob_action;
            (Util.assert_balance_is_at_least bob expected_bob_balance)])
            
let invalid_claim =
  Breath.Model.case
    "claim"
    "invalid claims are "
    (fun (level : Breath.Logger.level) ->
       let (_, (alice, bob, _carol)) = Breath.Context.init_default () in
       let stake = 100tez in
       let contract =
         Util.originate
           level
           alice.address
           [bob.address;]
           None
           stake
           in
       let bob_action =
         Breath.Context.act_as
           bob
           (Util.call
              contract
              Claim_stake
              0tez) in
       Breath.Result.reduce
          [ Breath.Expect.fail_with_message "SUBJECT IS LIVING THEIR BEST LIFE HOW DARE YOU" bob_action; ])

let () =
  Breath.Model.run_suites
    Trace
    [Breath.Model.suite "My test" [
      approved_quit
      ; unapproved_quit 
      ; impersonating_quit
      ; keep_alive 
      ; add_arbiter
      ; add_stake
      ; valid_claim
      ; invalid_claim
      ]]

// 195000000mutez
// 197682000mutez