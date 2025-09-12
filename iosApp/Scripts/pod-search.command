#!/bin/sh

echo "Pod name:"
read POD_NAME

pod search $POD_NAME
