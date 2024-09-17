import 'dart:io';

import 'package:flutter_code_organizer/src/headers/header_inspector/header_inspector_exception.dart';

class TestHeaderInspectorHandleItemData {
  const TestHeaderInspectorHandleItemData({
    required this.file,
    required this.source,
    this.forbiddenThemselfPackageImports,
    this.forbiddenOtherFeaturesPackageImports,
    this.forbiddenRelativeImports,
    this.forbiddenPackageExports,
    this.forbiddenOtherFeaturesRelativeExports,
  });

  final File file;
  final String source;
  final HeaderInspectorExceptionType? forbiddenThemselfPackageImports;
  final HeaderInspectorExceptionType? forbiddenOtherFeaturesPackageImports;
  final HeaderInspectorExceptionType? forbiddenRelativeImports;
  final HeaderInspectorExceptionType? forbiddenPackageExports;
  final HeaderInspectorExceptionType? forbiddenOtherFeaturesRelativeExports;

  static List<TestHeaderInspectorHandleItemData> list(File file) {
    return [
      TestHeaderInspectorHandleItemData(
        file: file, // 1
        source: "import 'dart:async';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 2
        source: "import 'package:flutter/material.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 3
        source: "import 'package:app/src/feature_a0.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 4
        source: "import 'package:app/src/feature_a0/feature_a0.dart';",
        forbiddenThemselfPackageImports:
        HeaderInspectorExceptionType.themselfPackageImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 5
        source: "import 'package:app/src/feature_a0/feature_a1.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 6
        source:
        "import 'package:app/src/feature_a0/feature_a1/feature_a1.dart';",
        forbiddenThemselfPackageImports:
        HeaderInspectorExceptionType.themselfPackageImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 7
        source:
        "import 'package:app/src/feature_a0/feature_a1/feature_a2.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 8
        source:
        "import 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a2.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 9
        source:
        "import 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a3.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 10
        source: "import 'feature_a0/feature_a1/feature_a2/feature_a4.dart';",
        forbiddenRelativeImports: HeaderInspectorExceptionType.relativeImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 11
        source: "import '../feature_a0/feature_a1/feature_a2/feature_a4.dart';",
        forbiddenRelativeImports: HeaderInspectorExceptionType.relativeImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 12
        source: "import 'package:app/src/feature_b0.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 13
        source: "import 'package:app/src/feature_b0/feature_b0.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 14
        source: "import 'package:app/src/feature_b0/feature_b1.dart';",
        forbiddenOtherFeaturesPackageImports:
        HeaderInspectorExceptionType.otherFeaturesPackageImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 15
        source:
        "import 'package:app/src/feature_b0/feature_b1/feature_b1.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 16
        source:
        "import 'package:app/src/feature_b0/feature_b1/feature_b2.dart';",
        forbiddenOtherFeaturesPackageImports:
        HeaderInspectorExceptionType.otherFeaturesPackageImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 17
        source:
        "import 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b2.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 18
        source:
        "import 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b3.dart';",
        forbiddenOtherFeaturesPackageImports:
        HeaderInspectorExceptionType.otherFeaturesPackageImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 19
        source: "import 'feature_b0/feature_b1/feature_b2/feature_b4.dart';",
        forbiddenRelativeImports: HeaderInspectorExceptionType.relativeImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 20
        source: "import '../feature_b0/feature_b1/feature_b2/feature_b4.dart';",
        forbiddenRelativeImports: HeaderInspectorExceptionType.relativeImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 21
        source: "import 'package:other/src/feature_c0.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 22
        source: "import 'package:other/src/feature_c0/feature_c0.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 23
        source: "import 'package:other/src/feature_c0/feature_c1.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 24
        source:
        "import 'package:other/src/feature_c0/feature_c1/feature_c1.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 25
        source:
        "import 'package:other/src/feature_c0/feature_c1/feature_c2.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 26
        source:
        "import 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c2.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 27
        source:
        "import 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c3.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 28
        source: "import 'feature_c0/feature_c1/feature_c2/feature_c4.dart';",
        forbiddenRelativeImports: HeaderInspectorExceptionType.relativeImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 29
        source: "import '../feature_c0/feature_c1/feature_c2/feature_c4.dart';",
        forbiddenRelativeImports: HeaderInspectorExceptionType.relativeImports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 30
        source: "export 'dart:async';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 31
        source: "export 'package:flutter/material.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 32
        source: "export 'package:app/src/feature_a0.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 33
        source: "export 'package:app/src/feature_a0/feature_a0.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 34
        source: "export 'package:app/src/feature_a0/feature_a1.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 35
        source:
        "export 'package:app/src/feature_a0/feature_a1/feature_a1.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 36
        source:
        "export 'package:app/src/feature_a0/feature_a1/feature_a2.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 37
        source:
        "export 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a2.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 38
        source:
        "export 'package:app/src/feature_a0/feature_a1/feature_a2/feature_a3.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 39
        source: "export 'feature_a0/feature_a1/feature_a2/feature_a4.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 40
        source: "export '../feature_a0/feature_a1/feature_a2/feature_a4.dart';",
        forbiddenOtherFeaturesRelativeExports:
        HeaderInspectorExceptionType.relativeExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 41
        source: "export 'package:app/src/feature_b0.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 42
        source: "export 'package:app/src/feature_b0/feature_b0.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 43
        source: "export 'package:app/src/feature_b0/feature_b1.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 44
        source:
        "export 'package:app/src/feature_b0/feature_b1/feature_b1.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 45
        source:
        "export 'package:app/src/feature_b0/feature_b1/feature_b2.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 46
        source:
        "export 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b2.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 47
        source:
        "export 'package:app/src/feature_b0/feature_b1/feature_b2/feature_b3.dart';",
        forbiddenPackageExports: HeaderInspectorExceptionType.packageExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 48
        source: "export 'feature_b0/feature_b1/feature_b2/feature_b4.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 49
        source: "export '../feature_b0/feature_b1/feature_b2/feature_b4.dart';",
        forbiddenOtherFeaturesRelativeExports:
        HeaderInspectorExceptionType.relativeExports,
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 50
        source: "export 'package:other/src/feature_c0.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 51
        source: "export 'package:other/src/feature_c0/feature_c0.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 52
        source: "export 'package:other/src/feature_c0/feature_c1.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 53
        source:
        "export 'package:other/src/feature_c0/feature_c1/feature_c1.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 54
        source:
        "export 'package:other/src/feature_c0/feature_c1/feature_c2.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 55
        source:
        "export 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c2.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 56
        source:
        "export 'package:other/src/feature_c0/feature_c1/feature_c2/feature_c3.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 57
        source: "export 'feature_c0/feature_c1/feature_c2/feature_c4.dart';",
      ),
      TestHeaderInspectorHandleItemData(
        file: file, // 58
        source: "export '../feature_c0/feature_c1/feature_c2/feature_c4.dart';",
        forbiddenOtherFeaturesRelativeExports:
        HeaderInspectorExceptionType.relativeExports,
      ),
    ];
  }
}