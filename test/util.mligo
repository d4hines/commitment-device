#import "../src/contract.mligo" "Contract"
#import "../breathalyzer/lib/lib.mligo" "Breath"
#import "../breathalyzer/examples/auction/src/auction_sc.mligo" "Auction"

type originated = Breath.Contract.originated

let call (contract : (Contract.parameter, Contract.storage) originated) (param : Contract.parameter) (qty: tez) () =
  Breath.Contract.transfert_to contract param qty

let assert_balance_is_at_least
    (actor: Breath.Context.actor)
    (expected_amount: tez) : Breath.Result.result =
    let actual_amount = Test.get_balance actor.address in
    Breath.Assert.is_true ("Expected at least: " ^ Test.to_string expected_amount ^ " but got: " ^ Test.to_string actual_amount)
    (actual_amount >= expected_amount)

let assert_state
    (contract: (Contract.parameter, Contract.storage) originated)
    (f : Contract.storage -> bool)
    : Breath.Result.result =
  let storage = Breath.Contract.storage_of contract in
  Breath.Assert.is_true "Contract state did not match predicate" (f storage)

let assert_balance
    (contract: (Contract.parameter, Contract.storage) originated)
    (amount : tez)
    : Breath.Result.result =
  let balance = Test.get_balance contract.originated_address in
  Breath.Assert.is_equal ("Expected balance of " ^ Test.to_string amount ^ "but got " ^ Test.to_string balance)
    amount
    balance

let originate
  (level : Breath.Logger.level)
  (subject : address)
  (arbiters : address list)
  (time : timestamp option)
  (stake : tez)
  =
  let timestamp =
    match time with
      Some time -> time
    | None -> Tezos.get_now () in
  let arbiters =
    List.fold_left
      (fun (acc, add : (address set) * address) ->
         Set.add add acc)
      (Set.empty : address set)
      arbiters in
  let initial_storage : Contract.storage =
    {last_keep_alive = timestamp;
     subject = subject;
     arbiters = arbiters;
     arbiter_approved_quit = false} in
  Breath.Contract.originate
    level
    "my_contract"
    Contract.main
    initial_storage
    stake
