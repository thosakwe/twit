import 'package:http/http.dart' as http;
import 'twit.dart';
export 'twit.dart';

class Twit extends TwitBase {
  Twit(TwitterCredentials credentials, {String apiRoot, bool debug})
      : super(credentials, new http.Client(),
            apiRoot: apiRoot, debug: debug == true);
}
