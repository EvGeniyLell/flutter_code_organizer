#!/usr/bin/env bash

flutter pub get

dart format -l 80 .

cd ..
dart run flutter_code_organizer:headers_sort -h
dart run flutter_code_organizer:headers_inspect
