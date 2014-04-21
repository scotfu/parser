#/usr/bin/env bash
for i in {1..34}; do python imp4.py test/test1/x$i.cfg > test/test1/x$i.out.mine;done
