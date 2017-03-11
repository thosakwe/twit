import 'package:test/test.dart';
import 'package:twit/io.dart';
import 'common.dart';

main() {
  Twit twit;

  setUp(() async {
    twit = new Twit(await loadCredentialsFromEnvironment());
  });

  tearDown(() => twit.close());

  test('user streams', () async {
    var stream = twit.stream('https://userstream.twitter.com/1.1/user.json');
    var data = await stream.skip(1).first;
    print('Data: $data');
    expect(data, isMap);
  });
}
