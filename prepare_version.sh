#!/usr/bin/env bash

VERSION=`git describe --always --tags --dirty`

if ! git diff --quiet; then
  VERSION="${VERSION}-$(date +%Y%m%d%H%M%S)"
fi

echo $VERSION