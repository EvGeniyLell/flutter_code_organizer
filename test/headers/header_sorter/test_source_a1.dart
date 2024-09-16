// ignore_for_file: unnecessary_raw_strings
import '../test_source/test_source.dart';
export '../test_source/test_source.dart';

const sourceA1 = TestSource(
  projectName: 'fx',
  description: 'A1: all imports, exports, parts with spaces',
  source: r'''
library flutter_code_inspector;

/// TestSampleData.
/// Description of the sample data.
  
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fx/src/account/business_objects/account_subscription_type.dart';
import 'package:fx/src/common/common.dart'
    hide
        CoordinateMapperExtensions,
        CoordinateDtoMapperExtensions,
        CoordinateMapper,
        CoordinateDtoMapper;

export 'cubits/splash_cubit.dart';
export 'ui/splash_page_builder.dart';
export 'package:fx/src/splash_screen/ui/splash_page_builder.dart';
export 'dart:io';
export 'package:flutter/src/splash_screen/ui/splash_page_builder.dart';
export 'package:mac_os/src/splash_screen/ui/splash_page_builder.dart';
import 'package:fx/src/account/business_objects/white_label.dart';
import 'package:fx/src/common/common.dart';
export '../splash_screen/ui/splash_page_builder.dart';
import 'package:fx/src/dictionary/dictionary.dart';
import 'package:fx/src/notifications/notifications.dart';
import 'notifications/notifications.dart';
import '../notifications/notifications.dart';

part 'account.g.dart';

part 'account.freezed.dart';

@freezed
class Account with _$Account implements HasToJson {
  const factory Account({
    required Region region,
    required String country2Code,
    required WhiteLabel whiteLabel,
    required String organisationId,
    required int organisationCxId,
    required String organisationDisplayName,
    required AccountSubscriptionType subscriptionType,
    required bool invoicePermitted,
    required LocationRecord homeLocation,
    required String defaultWeightUnitApiKey,
    required List<NotificationSettings> settings,
    required bool mobilePpmEnabled,
    String? phoneNumber,
    bool? enablePostLoadEmails,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

''',
  result: r'''
library flutter_code_inspector;

/// TestSampleData.
/// Description of the sample data.
  
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fx/src/account/business_objects/account_subscription_type.dart';
import 'package:fx/src/account/business_objects/white_label.dart';
import 'package:fx/src/common/common.dart'
    hide
        CoordinateMapperExtensions,
        CoordinateDtoMapperExtensions,
        CoordinateMapper,
        CoordinateDtoMapper;
import 'package:fx/src/common/common.dart';
import 'package:fx/src/dictionary/dictionary.dart';
import 'package:fx/src/notifications/notifications.dart';

import '../notifications/notifications.dart';
import 'notifications/notifications.dart';

export 'dart:io';

export 'package:flutter/src/splash_screen/ui/splash_page_builder.dart';

export 'package:mac_os/src/splash_screen/ui/splash_page_builder.dart';

export 'package:fx/src/splash_screen/ui/splash_page_builder.dart';

export '../splash_screen/ui/splash_page_builder.dart';
export 'cubits/splash_cubit.dart';
export 'ui/splash_page_builder.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account implements HasToJson {
  const factory Account({
    required Region region,
    required String country2Code,
    required WhiteLabel whiteLabel,
    required String organisationId,
    required int organisationCxId,
    required String organisationDisplayName,
    required AccountSubscriptionType subscriptionType,
    required bool invoicePermitted,
    required LocationRecord homeLocation,
    required String defaultWeightUnitApiKey,
    required List<NotificationSettings> settings,
    required bool mobilePpmEnabled,
    String? phoneNumber,
    bool? enablePostLoadEmails,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

''',
  imports: r'''
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fx/src/account/business_objects/account_subscription_type.dart';
import 'package:fx/src/account/business_objects/white_label.dart';
import 'package:fx/src/common/common.dart'
    hide
        CoordinateMapperExtensions,
        CoordinateDtoMapperExtensions,
        CoordinateMapper,
        CoordinateDtoMapper;
import 'package:fx/src/common/common.dart';
import 'package:fx/src/dictionary/dictionary.dart';
import 'package:fx/src/notifications/notifications.dart';

import '../notifications/notifications.dart';
import 'notifications/notifications.dart';
''',
  exports: r'''
export 'dart:io';

export 'package:flutter/src/splash_screen/ui/splash_page_builder.dart';

export 'package:mac_os/src/splash_screen/ui/splash_page_builder.dart';

export 'package:fx/src/splash_screen/ui/splash_page_builder.dart';

export '../splash_screen/ui/splash_page_builder.dart';
export 'cubits/splash_cubit.dart';
export 'ui/splash_page_builder.dart';
''',
  parts: r'''
part 'account.freezed.dart';
part 'account.g.dart';
''',
);
