String getFileData() {
  return r'''
library flutter_code_inspector;

/// TestSampleData.
/// Description of the sample data.
  
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/src/account/business_objects/account_subscription_type.dart';
import 'package:app/src/common/common.dart'
    hide
        CoordinateMapperExtensions,
        CoordinateDtoMapperExtensions,
        CoordinateMapper,
        CoordinateDtoMapper;

export 'cubits/splash_cubit.dart';
export 'ui/splash_page_builder.dart';
export 'package:app/src/splash_screen/ui/splash_page_builder.dart';
export 'dart:io';
export 'package:flutter/src/splash_screen/ui/splash_page_builder.dart';
export 'package:mac_os/src/splash_screen/ui/splash_page_builder.dart';
import 'package:app/src/account/business_objects/white_label.dart';
import 'package:app/src/common/common.dart';
export '../splash_screen/ui/splash_page_builder.dart';
import 'package:app/src/dictionary/dictionary.dart';
import 'package:app/src/notifications/notifications.dart';
import 'notifications/notifications.dart';
import '../notifications/notifications.dart';
import 'package:solar/solar.dart';


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

''';
}
