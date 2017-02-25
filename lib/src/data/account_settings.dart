class TwitterAccountSettings {
  bool alwaysUseHttps,
      discoverableByEmail,
      geoEnabled,
      protected,
      showAllInlineMedia,
      useCookiePersonalization;
  String language, screenName;
  TwitterAccountSettingsContributorRequest allowContributorRequest;
  TwitterAccountSettingsTimeZone timeZone;
  final List<TwitterAccountSettingsTrendLocation> trendLocations = [];
}

enum TwitterAccountSettingsContributorRequest { ALL }

class TwitterAccountSettingsSleepTime {
  bool enabled;
  DateTime endTime, startTime;
}

class TwitterAccountSettingsTimeZone {
  String name, timeZoneInfoName;
  int utcOffset;
}

class TwitterAccountSettingsTrendLocation {
  String country, countryCode, name, url;
  int parentId, woeId;
  TwitterAccountSettingsTrendLocationPlaceType placeType;
}

class TwitterAccountSettingsTrendLocationPlaceType {
  int code;
  String name;
}
