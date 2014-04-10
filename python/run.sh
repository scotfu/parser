#/usr/bin/env bash
for i in {1..10}; do python imp4.py test/x$i.cfg > test/x$i.out.mine;done