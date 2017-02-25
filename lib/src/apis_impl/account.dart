part of twit.client;

class _TwitterAccountsApiImpl implements TwitterAccountApi {
  final Twit _twit;

  _TwitterAccountsApiImpl(this._twit);

  @override
  Future<TwitterAccountSettings> getSettings() =>
      _twit.get('/account/settings.json').then<TwitterAccountSettings>(
          (json) => new TwitterAccountSettings.fromJson(json));
}
