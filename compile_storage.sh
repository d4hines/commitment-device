#!/usr/bin/env bash

./ligo compile storage \
    ./src/contract.mligo \
    '{last_keep_alive = ("2022-11-26t10:10:10Z" : timestamp); subject = ("tz1ioWJ8pptxsnuZWU2uvGjptfBn8NaNFskA" : address); arbiters = (Set.empty : address set); arbiter_approved_quit = false; }'
