// ignore_for_file: unnecessary_raw_strings
import '../test_source/test_source.dart';
export '../test_source/test_source.dart';

const sourceA1 = TestSource(
  projectName: 'fx',
  description: 'A1: all imports, exports, parts with spaces',
  source: r'''
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fx/src/account/account.dart';
import 'package:fx/src/authentication/authentication.dart';
import 'package:fx/src/common/common.dart';
import 'package:fx/src/common/business_objects/coordinate.dart';
import 'package:fx/src/dashboard/dashboard.dart';
import 'package:fx/src/design_system/design_system.dart';
import 'package:fx/src/host_device/host_device.dart';
import 'package:fx/src/legal/legal.dart';
import 'package:fx/src/localizations.dart';
import 'package:fx/src/splash/cubits/splash_cubit.dart';

''',
  result: '',
  imports: '',
  exports: '',
  parts: '',
);
