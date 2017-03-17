import 'package:test/test.dart';
import 'package:twit/io.dart';
import 'common.dart';

main() {
  Twit twit;

  setUp(() async {
    twit = new Twit(await loadCredentialsFromEnvironment());
  });

  tearDown(() => twit.close());

  test('verify credentials', () async {
    var credentials = await twit.get('/account/verify_credentials.json');
    print('Credentials: $credentials');
  });

  test('skip status', () async {
    var credentials = await twit
        .get('/account/verify_credentials.json', {'skip_status': 'true'});
    print('Credentials: $credentials');
  });

  group('settings', () {
    test('get', () async {
      var settingsMap = await twit.get('/account/settings.json');
      print('Settings: $settingsMap');

      var settingsObject = await twit.account.getSettings();
      print('Screen name: ${settingsObject.screenName}');

      expect(settingsMap['screen_name'], equals(settingsObject.screenName));
    });
  });
}
