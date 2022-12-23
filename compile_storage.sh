#!/usr/bin/env bash

./ligo compile storage \
    ./contract.mligo \
    '{last_keep_alive = ("2022-11-26t10:10:10Z" : timestamp); subject = ("tz1MCkDAhUqx2f7QkyWgawp1CzDyX4t3br7c" : address); session_key = ("tz1MCkDAhUqx2f7QkyWgawp1CzDyX4t3br7c" : address); arbiters = (Set.empty : address set); arbiter_approved_quit = false; }'
