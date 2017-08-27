#!/bin/bash -e

# XXX We achieve one goal: add the musl overlay to the stage3.

source /etc/profile
env-update
emerge -b1q layman
layman -L

layman -a musl || true # don't fail if musl overlay has been already added
layman -S              # update musl overlay if we were added perviously
