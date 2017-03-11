import 'dart:async';

abstract class TwitterStreams {
  Stream<String> get onData;
  Stream get onDirectMessage;
  Stream<Map> get onJson;
  Stream get onTweet;
}
