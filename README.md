# Commitment Device

![](https://upload.wikimedia.org/wikipedia/commons/8/8d/John_William_Waterhouse_-_Ulysses_and_the_Sirens_%281891%29.jpg)

This is a very simple commitment device contract.

The idea is this:
- Suppose you want to form some positive habit, and you want a trusted friend to keep you accountable.
- You deploy this contract with yourself as the subject and some amount XTZ at stake, and list your friends as arbiters of the contract
- Every day, you do the habit, and send a `Keep_alive` operation
    - It's up to you to be honest (and your friends to keep you honest)
- If 36 hours pass and you don't send the keep-alive, then anyone can steal your stake
    - Why 36 hours? Because 24 is the ideal, but it seems real life would demand some buffer.
- If you want out of the deal, you have two choices:
    - Get one of your arbiter friends to send an `Approve_quit` operation. Then you can send a `Quit` operation to gracefully get out of the contract and get your stake back.
    - Quit without their approval. You'll still get your stake back, but the contract will call you out on it by emitting an on-chain event,
      permanently recording you as a quitter in blockchain history...

I wrote this for myself in over a weekend - don't expect much from it.

## WARNING

THIS CONTRACT HAS NOT BEEN AUDITED! USE AT YOUR OWN RISK. 
