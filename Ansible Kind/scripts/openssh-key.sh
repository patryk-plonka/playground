#! /bin/bash

ssh-keygen -q -t ed25519 -C "default key" -N '' -f ~/.ssh/id_ed25519 >/dev/null 2>&1
ssh-keygen -q -t ed25519 -C "ansible key" -N '' -f ~/.ssh/id_ansible >/dev/null 2>&1