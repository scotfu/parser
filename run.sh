#/usr/bin/env bash
for i in {1..45}; do guile imp2.scm test/test1/x$i.cfg > test/test1/x$i.out.mine;done
