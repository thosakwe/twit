part of twit.client;

class _TwitterStreamsImpl implements TwitterStreams {
  final StreamController _onTweet = new StreamController();
  
  // TODO: implement onTweet
  @override
  Stream get onTweet => null;

  void _close() {
    _onTweet.close();
  }
}