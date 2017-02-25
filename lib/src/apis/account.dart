import 'dart:async';
import '../data/account_settings.dart';

abstract class TwitterAccountApi {
  Future<TwitterAccountSettings> getSettings();
}