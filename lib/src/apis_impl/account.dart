part of twit.client;

class _TwitterAccountsApiImpl implements TwitterAccountApi {
  final Twit _twit;

  _TwitterAccountsApiImpl(this._twit);
  
  @override
  Future<TwitterAccountSettings> getSettings() {
    // TODO: implement getSettings
  }
}