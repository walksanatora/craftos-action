#!/bin/bash
docker build -t craftosaction .
cd test
docker build -t craftosaction-test .
docker run -t craftosaction-test