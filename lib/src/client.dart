library twit.client;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:charcode/ascii.dart';
import 'package:crypto/crypto.dart';
import 'package:http/src/base_client.dart' as http;
import 'package:http/src/request.dart' as http;
import 'package:http/src/multipart_file.dart' as http;
import 'package:http/src/multipart_request.dart' as http;
import 'package:http/src/response.dart' as http;
import 'package:http/src/streamed_response.dart';
import 'package:http/src/base_request.dart';
import 'package:random_string/random_string.dart' as rs;
import 'apis/apis.dart';
import 'data/data.dart';
import 'credentials.dart';
part 'apis_impl/account.dart';

const String UPLOAD_ENDPOINT =
    'https://upload.twitter.com/1.1/media/upload.json';

final RegExp _http = new RegExp(r'^https?://');
final RegExp _straySlashes = new RegExp(r'(^/+)|(/+$)');

abstract class TwitBase {
  final TwitterCredentials credentials;
  final http.BaseClient _innerClient;

  TwitterAccountApi _account;

  TwitterAccountApi get account => _account;

  TwitBase(this.credentials, this._innerClient) {
    _account = new _TwitterAccountsApiImpl(this);
  }

  Uri _makeUrl(String path) {
    if (path.startsWith(_http)) return Uri.parse(path);
    return Uri.parse(
        'https://api.twitter.com/1.1/' + path.replaceAll(_straySlashes, ''));
  }

  String _createSignature(
      String method, String uriString, Map<String, dynamic> params,
      {String tokenSecret: ""}) {
    // Not only do we need to sort the parameters, but we need to URI-encode them as well.
    var encoded = new SplayTreeMap();
    for (String key in params.keys) {
      encoded[Uri.encodeComponent(key)] =
          Uri.encodeComponent(params[key].toString());
    }

    String collectedParams =
        encoded.keys.map((key) => "$key=${encoded[key]}").join("&");

    String baseString =
        "$method&${Uri.encodeComponent(uriString)}&${Uri.encodeComponent(
        collectedParams)}";

    String signingKey =
        "${Uri.encodeComponent(credentials.consumerSecret)}&$tokenSecret";

    // After you create a base string and signing key, we need to hash this via HMAC-SHA1
    var hmac = new Hmac(sha1, signingKey.codeUnits);

    // The returned signature should be the resulting hash, Base64-encoded
    return BASE64.encode(hmac.convert(baseString.codeUnits).bytes);
  }

  void close() => _innerClient.close();

  Future<StreamedResponse> send(BaseRequest request,
      [Map<String, dynamic> params = const {}]) {
    var headers = new Map<String, String>.from(request.headers);
    headers["oauth_version"] = "1.0";
    headers["oauth_consumer_key"] = credentials.consumerKey;

    // The implementation of _randomString doesn't matter - just generate a 32-char
    // alphanumeric string.
    headers["oauth_nonce"] = rs.randomAlphaNumeric(32);
    headers["oauth_signature_method"] = "HMAC-SHA1";
    headers["oauth_timestamp"] =
        (new DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    if (credentials.accessToken != null) {
      headers["oauth_token"] = credentials.accessToken;
    }

    // var request = await _client.openUrl(method, Uri.parse("$_ENDPOINT$path"));

    headers['oauth_signature'] = _createSignature(
        request.method,
        request.url.toString().replaceAll("?${request.url.query}", ""),
        {}..addAll(headers)..addAll(params ?? {}),
        tokenSecret: credentials.accessTokenSecret);

    var oauthString = headers.keys
        .map((name) => '$name="${Uri.encodeComponent(headers[name])}"')
        .join(", ");

    request.headers['authorization'] = 'OAuth $oauthString';

    return _innerClient.send(request);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.headers['content-type']?.contains('application/json') ==
        true) {
      if (response.statusCode != 200 && response.statusCode != 201)
        throw new TwitterException.fromResponse(response);
      else
        return JSON.decode(response.body);
    } else
      throw new StateError(
          'Twitter response returned body with status code ${response.statusCode} and content type "${response.headers["content-type"]}":\n${response.body}');
  }

  Future<Map<String, dynamic>> get(String path, [Map<String, String> params]) =>
      send(new http.Request('GET', _makeUrl(path)))
          .then(http.Response.fromStream)
          .then(_processResponse);

  Future<Map<String, dynamic>> post(String path, [Map<String, String> params]) {
    var request = new http.Request('POST', _makeUrl(path));

    if (params?.isNotEmpty == true) request.bodyFields = params;

    return send(request, params)
        .then(http.Response.fromStream)
        .then(_processResponse);
  }

  Stream stream(String path, [Map<String, dynamic> params]) {
    var ctrl = new StreamController();
    var rq = new http.Request('POST', _makeUrl(path));

    send(rq, params).then((rs) async {
      if (rs.headers['content-type']?.contains('application/json') == true) {
        if (rs.statusCode != 200 && rs.statusCode != 201)
          throw new TwitterException.fromResponse(
              await http.Response.fromStream(rs));
      } else {
        var body = await rs.stream.transform(UTF8.decoder).join();
        throw new StateError(
            'Twitter response returned body with status code ${rs.statusCode} and content type "${rs.headers["content-type"]}":\n$body');
      }

      rs.stream.transform(new _CrlfSplitter()).pipe(ctrl);
    });

    return ctrl.stream;
  }

  /// Uploads data from a stream using the chunked media upload API.
  Future<TwitterMediaUploadInfo> upload(
      Stream<List<int>> stream, String mimeType, int size,
      {String mediaCategory,
      Iterable<String> additionalOwners: const [],
      Encoding encoding: UTF8}) async {
    // https://dev.twitter.com/rest/reference/post/media/upload-init
    var initParams = {
      'command': 'INIT',
      'total_bytes': size.toString(),
      'media_type': mimeType
    };

    if (mediaCategory != null) initParams['media_category'] = mediaCategory;

    if (additionalOwners?.isNotEmpty == true)
      initParams['additional_owners'] = additionalOwners.join(',');

    var initRequest = new http.Request('POST', Uri.parse(UPLOAD_ENDPOINT))
      ..bodyFields = initParams;
    var initResponse =
        await send(initRequest, initParams).then(http.Response.fromStream);

    if (initResponse.statusCode != 200)
      throw new TwitterMediaUploadInfoException(
          'Failed to initialize chunked media upload.',
          new TwitterException.fromResponse(initResponse));

    var uploadInfo =
        new TwitterMediaUploadInfo.fromJson(JSON.decode(initResponse.body));
    var mediaId = uploadInfo.mediaIdString;
    int i = 0;

    await for (var chunk in stream) {
      var appendParams = {
        'command': 'APPEND',
        'media_id': mediaId,
        'segment_index': (++i).toString()
      };
      var appendRequest =
          new http.MultipartRequest('POST', Uri.parse(UPLOAD_ENDPOINT));
      appendRequest
        ..fields.addAll(appendParams)
        ..files.add(new http.MultipartFile.fromBytes('media', chunk));

      var appendResponse = await send(appendRequest, appendParams)
          .then(http.Response.fromStream);

      if (appendResponse.statusCode != 200)
        throw new TwitterMediaUploadInfoException(
            'Failed to upload chunk (index: $i).',
            new TwitterException.fromResponse(appendResponse));
    }

    var finalizeParams = {'command': 'FINALIZE', 'media_id': mediaId};
    var finalizeRequest = new http.Request('POST', Uri.parse(UPLOAD_ENDPOINT))
      ..bodyFields = finalizeParams;
    var finalizeResponse = await send(finalizeRequest, finalizeParams)
        .then(http.Response.fromStream);

    if (finalizeResponse.statusCode != 200)
      throw new TwitterMediaUploadInfoException(
          'Failed to finalize chunked media upload.',
          new TwitterException.fromResponse(finalizeResponse));

    var finalizeInfo =
        new TwitterMediaUploadInfo.fromJson(JSON.decode(finalizeResponse.body));

    if (finalizeInfo.processingInfo == null) return finalizeInfo;

    Future<TwitterMediaUploadInfo> awaitSuccess() async {
      var statusParams = {'command': 'STATUS', 'media_id': mediaId};
      var statusRequest = new http.Request('GET', Uri.parse(UPLOAD_ENDPOINT))
        ..bodyFields = statusParams;
      var statusResponse = await send(statusRequest, statusParams)
          .then(http.Response.fromStream);

      if (statusResponse.statusCode != 200)
        throw new TwitterException.fromResponse(statusResponse);

      var statusInfo = new TwitterMediaUploadInfo.fromJson(
          JSON.decode(finalizeResponse.body));

      if (statusInfo.processingInfo == null)
        return statusInfo;
      else {
        switch (statusInfo.processingInfo.state) {
          case TwitterMediaUploadInfoProcessingInfoState.PENDING:
            return await new Future.delayed(new Duration(
                    seconds: statusInfo.processingInfo.checkAfterSecs))
                .then((_) => awaitSuccess());
          case TwitterMediaUploadInfoProcessingInfoState.SUCCEEDED:
            return statusInfo;
          case TwitterMediaUploadInfoProcessingInfoState.FAILED:
            throw new TwitterMediaUploadInfoException(
                'Failed to upload chunked media.',
                statusInfo.processingInfo.error);
            break;
          default:
            throw new StateError(
                'Media upload processing info contains a unrecognized state.');
        }
      }
    }

    return await awaitSuccess();
  }
}

class _CrlfSplitter implements StreamTransformer<List<int>, Object> {
  final List<int> buf = [];
  int last;

  @override
  Stream<Object> bind(Stream<List<int>> stream) {
    var ctrl = new StreamController();

    stream.listen(
        (chunk) {
          for (var ch in chunk) {
            if (last == $cr && ch == $lf) {
              var str = UTF8.decode(buf..removeLast());

              try {
                if (str.isNotEmpty) ctrl.add(JSON.decode(str));
              } catch (e, st) {
                ctrl.addError(e, st);
              }

              buf.clear();
              last = null;
            } else {
              buf.add(last = ch);
            }
          }
        },
        cancelOnError: true,
        onError: ctrl.addError,
        onDone: () {
          buf.clear();
          ctrl.close();
        });

    return ctrl.stream;
  }
}
