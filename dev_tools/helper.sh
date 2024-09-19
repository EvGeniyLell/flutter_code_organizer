#!/usr/bin/env bash

flutter pub get

dart format -l 80 .

dart run flutter_code_organizer:headers_sort
dart run flutter_code_organizer:headers_inspect
dart run flutter_code_organizer:localization_inspect

flutter test test