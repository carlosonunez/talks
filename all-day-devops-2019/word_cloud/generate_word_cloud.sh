#!/usr/bin/env bash
LC_ALL='C' # enabled to work around some encoding issues
cat sites/*.txt | \
  tr " " "\n" | \
  tr '[:upper:]' '[:lower:]' | \
  sort | uniq -c | sort -r > raw.txt
