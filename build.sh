#!/bin/bash
VERSION=$(cat VERSION.txt)
docker build -t "atulkpatel/non-functional-testing:${VERSION}" -t atulkpatel/non-functional-testing:latest .
