#/usr/bin/env bash
for i in {1..45}; do cmp x$i.out x$i.out.mine ;done
