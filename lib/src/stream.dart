import 'dart:async';

abstract class TwitterStreams {
  Stream get onTweet;
}
