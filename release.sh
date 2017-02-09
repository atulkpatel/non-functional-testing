#!/bin/bash
VERSION=$(cat VERSION.txt)
docker push "atulkpatel/non-functional-testing:${VERSION}"
docker push atulkpatel/non-functional-testing:latest
