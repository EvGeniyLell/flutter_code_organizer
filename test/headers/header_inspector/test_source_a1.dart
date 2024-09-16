// ignore_for_file: unnecessary_raw_strings
import '../test_source/test_source.dart';
export '../test_source/test_source.dart';

const sourceA1 = TestSource(
  projectName: 'app',
  description: 'A1: all imports, exports, parts with spaces',
  source: r'''
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app/src/feature_a0.dart';
import 'package:app/src/feature_a0/feature_a0.dart';
import 'package:app/src/feature_a0/feature_a1.dart';
import 'package:app/src/feature_a0/feature_a1/feature_a1.dart';
import 'package:app/src/feature_a0/feature_a1/feature_a2.dart';
import 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a2.dart';
import 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a3.dart';

import 'feature_a0/feature_a1/feature_a2/feature_a4.dart';
import '../feature_a0/feature_a1/feature_a2/feature_a4.dart';

import 'package:app/src/feature_b0.dart';
import 'package:app/src/feature_b0/feature_b0.dart';
import 'package:app/src/feature_b0/feature_b1.dart';
import 'package:app/src/feature_b0/feature_b1/feature_b1.dart';
import 'package:app/src/feature_b0/feature_b1/feature_b2.dart';
import 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b2.dart';
import 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b3.dart';

import 'feature_b0/feature_b1/feature_b2/feature_b4.dart';
import '../feature_b0/feature_b1/feature_b2/feature_b4.dart';

import 'package:other/src/feature_c0.dart';
import 'package:other/src/feature_c0/feature_c0.dart';
import 'package:other/src/feature_c0/feature_c1.dart';
import 'package:other/src/feature_c0/feature_c1/feature_c1.dart';
import 'package:other/src/feature_c0/feature_c1/feature_c2.dart';
import 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c2.dart';
import 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c3.dart';

import 'feature_c0/feature_c1/feature_c2/feature_c4.dart';
import '../feature_c0/feature_c1/feature_c2/feature_c4.dart';

// -- exports ---------------------------------------------------------------

export 'dart:async';

export 'package:flutter/material.dart';

export 'package:app/src/feature_a0.dart';
export 'package:app/src/feature_a0/feature_a0.dart';
export 'package:app/src/feature_a0/feature_a1.dart';
export 'package:app/src/feature_a0/feature_a1/feature_a1.dart';
export 'package:app/src/feature_a0/feature_a1/feature_a2.dart';
export 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a2.dart';
export 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a3.dart';

export 'feature_a0/feature_a1/feature_a2/feature_a4.dart';
export '../feature_a0/feature_a1/feature_a2/feature_a4.dart';

export 'package:app/src/feature_b0.dart';
export 'package:app/src/feature_b0/feature_b0.dart';
export 'package:app/src/feature_b0/feature_b1.dart';
export 'package:app/src/feature_b0/feature_b1/feature_b1.dart';
export 'package:app/src/feature_b0/feature_b1/feature_b2.dart';
export 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b2.dart';
export 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b3.dart';

export 'feature_b0/feature_b1/feature_b2/feature_b4.dart';
export '../feature_b0/feature_b1/feature_b2/feature_b4.dart';

export 'package:other/src/feature_c0.dart';
export 'package:other/src/feature_c0/feature_c0.dart';
export 'package:other/src/feature_c0/feature_c1.dart';
export 'package:other/src/feature_c0/feature_c1/feature_c1.dart';
export 'package:other/src/feature_c0/feature_c1/feature_c2.dart';
export 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c2.dart';
export 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c3.dart';

export 'feature_c0/feature_c1/feature_c2/feature_c4.dart';
export '../feature_c0/feature_c1/feature_c2/feature_c4.dart';

''',
  result: '',
  imports: '',
  exports: '',
  parts: '',
);
