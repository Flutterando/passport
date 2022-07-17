import 'package:passaport/passaport.dart';
import 'package:passaport/src/passport_local.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('passaport base ...', () async {
    final passport = Passport();

    passport.use(LocalStrategy(
      (request, next) async {
        final mapCredencial = LocalStrategy.basicExtractor(request);
        final credencial = LocalCredential.fromJson(mapCredencial);
        return next(request, credencial);
      },
    ));

    final handler = passport.authorization('local')(
      (request, [credential]) {
        return Response.ok('ok');
      },
    );

    final request = Request('GET', Uri.parse('http://localhost/login'), headers: {
      'authorization': 'basic amFjb2JAZmx1dHRlcnJhbmRvLmNvbTphYmMxMjM=',
    });

    final response = await handler(request);
    print(response);
  });
}

class LocalCredential {
  final String username;
  final String password;

  LocalCredential(this.username, this.password);

  static LocalCredential fromJson(dynamic json) {
    return LocalCredential(json['username'], json['password']);
  }
}
