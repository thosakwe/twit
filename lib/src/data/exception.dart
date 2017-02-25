import 'dart:convert';
import 'package:http/src/response.dart' as http;

class TwitterException implements Exception {
  int code;
  String name, message;

  TwitterException({this.code, this.name, this.message});

  factory TwitterException.fromJson(Map json) => new TwitterException(
      code: json['code'], name: json['name'], message: json['message']);

  factory TwitterException.fromResponse(http.Response response) =>
      new TwitterException.fromJson(JSON.decode(response.body));

  @override
  toString() => '$name: $message';

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'message': message};
  }
}
