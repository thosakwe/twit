import 'package:http/browser_client.dart' as http;
import 'twit.dart';
export 'twit.dart';

class Twit extends TwitBase {
  Twit(TwitterCredentials credentials)
      : super(credentials, new http.BrowserClient());
}
