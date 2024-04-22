#!/bin/bash


./hq job submit --stdout=none --stderr=none --array 1-10 "./sleep_1s.sh"
