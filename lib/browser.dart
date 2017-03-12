import 'package:http/browser_client.dart' as http;
import 'twit.dart';
export 'twit.dart';

class Twit extends TwitBase {
  Twit(TwitterCredentials credentials, {String apiRoot, bool debug})
      : super(credentials, new http.BrowserClient(),
            apiRoot: apiRoot, debug: debug == true);
}
