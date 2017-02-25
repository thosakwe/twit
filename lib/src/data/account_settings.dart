import 'twitter_data.dart';

class TwitterAccountSettings implements TwitterData {
  bool alwaysUseHttps,
      discoverableByEmail,
      discoverableByMobilePhone,
      displaySensitiveMedia,
      geoEnabled,
      protected,
      showAllInlineMedia,
      useCookiePersonalization;
  String language, screenName, translatorType;
  TwitterAccountRelationship allowContributorRequest,
      allowDMsFrom,
      allowDMGroupsFrom;
  TwitterAccountSettingsSleepTime sleepTime;
  TwitterAccountSettingsTimeZone timeZone;
  final Iterable<TwitterAccountSettingsTrendLocation> trendLocations;

  TwitterAccountSettings(
      {this.alwaysUseHttps,
      this.discoverableByEmail,
      this.discoverableByMobilePhone,
      this.displaySensitiveMedia,
      this.geoEnabled,
      this.protected,
      this.showAllInlineMedia,
      this.useCookiePersonalization,
      this.language,
      this.screenName,
      this.translatorType,
      this.allowContributorRequest,
      this.allowDMsFrom,
      this.allowDMGroupsFrom,
      this.sleepTime,
      this.timeZone,
      this.trendLocations});

  factory TwitterAccountSettings.fromJson(Map json) =>
      new TwitterAccountSettings(
          alwaysUseHttps: json['always_use_https'],
          discoverableByEmail: json['discoverable_by_email'],
          discoverableByMobilePhone: json['discoverable_by_mobile_phone'],
          displaySensitiveMedia: json['display_sensitive_media'],
          geoEnabled: json['geo_enabled'],
          language: json['language'],
          protected: json['protected'],
          screenName: json['screen_name'],
          showAllInlineMedia: json['show_all_inline_media'] == true,
          sleepTime: json['sleep_time'] is Map
              ? new TwitterAccountSettingsSleepTime.fromJson(json['sleep_time'])
              : null,
          timeZone: json['time_zone'] is Map
              ? new TwitterAccountSettingsTimeZone.fromJson(json['time_zone'])
              : null,
          trendLocations: json['trend_location'] is List
              ? json['trend_location'].map<TwitterAccountSettingsTrendLocation>(
                  (Map<String, dynamic> trendLocation) =>
                      new TwitterAccountSettingsTrendLocation.fromJson(
                          trendLocation))
              : null,
          useCookiePersonalization: json['use_cookie_personalization'] == true,
          allowContributorRequest:
              _parseRelationship(json['allow_contributor_request']?.toString()),
          allowDMsFrom: _parseRelationship(json['allow_dms_from']?.toString()),
          allowDMGroupsFrom:
              _parseRelationship(json['allow_dm_groups_from']?.toString()));
  @override
  Map<String, dynamic> toJson() {
    var result = {
      'always_use_https': alwaysUseHttps == true,
      'discoverable_by_email': discoverableByEmail == true,
      'discoverable_by_mobile_phone': discoverableByMobilePhone == true,
      'display_sensitive_media': displaySensitiveMedia == true,
      'geo_enabled': geoEnabled == true,
      'language': language,
      'protected': protected == true,
      'screen_name': screenName,
      'show_all_inline_media': showAllInlineMedia == true,
      'use_cookie_personalization': useCookiePersonalization == true,
      'allow_contributor_request':
          _stringifyRelationship(allowContributorRequest)
    };

    if (sleepTime != null) result['sleep_time'] = sleepTime.toJson();
    if (timeZone != null) result['time_zone'] = timeZone.toJson();
    if (trendLocations != null)
      result['trend_location'] = trendLocations
          .map<Map<String, dynamic>>((trendLocation) => trendLocation.toJson())
          .toList();

    return result;
  }
}

TwitterAccountRelationship _parseRelationship(String str) {
  switch (str) {
    case 'all':
      return TwitterAccountRelationship.ALL;
    case 'following':
      return TwitterAccountRelationship.FOLLOWING;
    default:
      return TwitterAccountRelationship.NONE;
  }
}

String _stringifyRelationship(TwitterAccountRelationship relationship) {
  switch (relationship) {
    case TwitterAccountRelationship.ALL:
      return 'all';
    case TwitterAccountRelationship.FOLLOWING:
      return 'following';
    default:
      return _stringifyRelationship(TwitterAccountRelationship.ALL);
  }
}

enum TwitterAccountRelationship { NONE, ALL, FOLLOWING }

class TwitterAccountSettingsSleepTime implements TwitterData {
  bool enabled;
  int endTime, startTime;

  TwitterAccountSettingsSleepTime({this.enabled, this.endTime, this.startTime});

  factory TwitterAccountSettingsSleepTime.fromJson(Map json) =>
      new TwitterAccountSettingsSleepTime(
          enabled: json['enabled'] == true,
          endTime: json['end_time'],
          startTime: json['start_time']);
  @override
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled == true,
      'end_time': endTime,
      'start_time': startTime
    };
  }
}

class TwitterAccountSettingsTimeZone implements TwitterData {
  String name, timeZoneInfoName;
  int utcOffset;

  TwitterAccountSettingsTimeZone(
      {this.name, this.timeZoneInfoName, this.utcOffset});

  factory TwitterAccountSettingsTimeZone.fromJson(Map json) =>
      new TwitterAccountSettingsTimeZone(
          name: json['name'],
          timeZoneInfoName: json['tzinfo_name'],
          utcOffset: json['utc_offset']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tzinfo_name': timeZoneInfoName,
      'utc_offset': utcOffset
    };
  }
}

class TwitterAccountSettingsTrendLocation implements TwitterData {
  String country, countryCode, name, url;
  int parentId, woeId;
  TwitterAccountSettingsTrendLocationPlaceType placeType;

  TwitterAccountSettingsTrendLocation(
      {this.country,
      this.countryCode,
      this.name,
      this.url,
      this.parentId,
      this.woeId,
      this.placeType});

  factory TwitterAccountSettingsTrendLocation.fromJson(Map json) =>
      new TwitterAccountSettingsTrendLocation(
          country: json['country'],
          countryCode: json['country_code'],
          name: json['name'],
          url: json['url'],
          parentId: json['parentid'],
          woeId: json['woeid'],
          placeType: json['place_type'] is Map
              ? new TwitterAccountSettingsTrendLocationPlaceType.fromJson(
                  json['place_type'])
              : null);

  @override
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'country_code': countryCode,
      'name': name,
      'url': url,
      'parentid': parentId,
      'woeid': woeId,
      'place_type': placeType?.toJson()
    };
  }
}

class TwitterAccountSettingsTrendLocationPlaceType implements TwitterData {
  int code;
  String name;

  TwitterAccountSettingsTrendLocationPlaceType({this.code, this.name});

  factory TwitterAccountSettingsTrendLocationPlaceType.fromJson(Map json) =>
      new TwitterAccountSettingsTrendLocationPlaceType(
          code: json['code'], name: json['name']);

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name};
  }
}
