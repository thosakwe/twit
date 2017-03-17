# twit
[![version 0.0.4](https://img.shields.io/badge/pub-0.0.4-red.svg)](https://pub.dartlang.org/packages/twit)
[![build status](https://travis-ci.org/thosakwe/twit.svg?branch=master)](https://travis-ci.org/thosakwe/twit)

Dart port of Tolga Tezel's Twitter client.

```dart
import 'dart:convert';
import 'package:twit/io.dart';

main() async {
    var twit = new Twit(
        new Credentials(consumerKey: ..., consumerSecret: ..., accessToken: ..., accessTokenSecret: ...));
    var stream = twit.stream('https://userstream.twitter.com/1.1/user.json');

    stream.listen((tweet) {
        print('Incoming Tweet: ' + tweet['text']);
    });
}