import 'dart:convert';
import 'package:http/src/response.dart' as http;
import 'twitter_data.dart';

class TwitterException implements Exception, TwitterData {
  http.Response _response;
  int code;
  String name, message;

  http.Response get response => _response;

  TwitterException(
      {this.code, this.name, this.message, http.Response response}) {
    _response = response;
  }

  factory TwitterException.fromJson(Map json) => new TwitterException(
      code: json['code'], name: json['name'], message: json['message']);

  factory TwitterException.fromResponse(http.Response response) {
    try {
      var json = JSON.decode(response.body);

      if (json['errors'] is List) {
        List<Map<String, dynamic>> errors = json['errors'];

        if (errors.length == 1)
          return new TwitterException.fromJson(errors.first)
            .._response = response;

        return new _TwitterMultipleExceptions(errors.map<TwitterException>(
            (json) => new TwitterException.fromJson(json)
              .._response = response)).._response = response;
      } else
        return new TwitterException.fromJson(json).._response = response;
    } catch (e) {
      return new TwitterException().._response = response;
    }
  }

  @override
  toString() {
    if (name != null && message != null)
      return '$name: $message';
    else if (name != null)
      return 'TwitterException: $name';
    else if (message != null)
      return 'TwitterException: $message';
    else if (code != null)
      return 'TwitterException: $code';
    else if (response != null)
      return 'TwitterException: status code ${response.statusCode}, body: ${response.body}';
    else
      return 'TwitterException: unknown name + message';
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'message': message};
  }
}

class _TwitterMultipleExceptions extends TwitterException {
  final Iterable<TwitterException> _children;

  _TwitterMultipleExceptions(this._children);

  @override
  toString() {
    var buf = new StringBuffer('Found ${_children.length} errors:');

    for (var child in _children) {
      buf.writeln('  * $child');
    }

    return buf.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'errors': _children
          .map<Map<String, dynamic>>((child) => child.toJson())
          .toList()
    };
  }
}
