import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dotenv/dotenv.dart' as env;
import 'package:twit/twit.dart';

Future<TwitterCredentials> loadCredentialsFromEnvironment() async {
  var file = new File('.env'), psr = new env.Parser();

  if (!await file.exists()) throw new StateError('No .env file found...');

  var loaded = await file
      .openRead()
      .transform(UTF8.decoder)
      .map<List<String>>((str) => str.split('\n'))
      .map<Map<String, String>>(psr.parse)
      .fold<Map<String, String>>({}, (out, map) => out..addAll(map));

  var credentials = new TwitterCredentials(
    consumerKey: loaded['TWITTER_KEY'],
    consumerSecret: loaded['TWITTER_SECRET'],
    accessToken: loaded['TWITTER_ACCESS_TOKEN'],
    accessTokenSecret: loaded['TWITTER_ACCESS_TOKEN_SECRET'],
  );

  print('Loaded credentials from environment: ${credentials.toJson()}');

  return credentials;
}
