import 'package:test/test.dart';
import 'package:twit/twit.dart';

main() {
  Twit twit;

  setUp(() async {

  });

  tearDown(() => twit.close());

  test('get settings', () async {
    var settings = await twit.account.getSettings();
  });
}