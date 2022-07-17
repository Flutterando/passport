import 'dart:async';

import 'package:shelf/shelf.dart';

import '../passaport.dart';

typedef LocalStrategyHandler = FutureOr<Response> Function(Request request, [dynamic user]);

class JwtStrategy extends Strategy {
  final FutureOr<Response> Function(Request request, LocalStrategyHandler next) verify;

  JwtStrategy(this.verify) : super('local');

  @override
  FutureOr<Response> execute(Request request, Map<String, dynamic> options, covariant LocalStrategyHandler next) {
    FutureOr<Response> _internalNext(Request request, [dynamic user]) {
      return next(request, user);
    }

    return verify(request, _internalNext);
  }

  static String bearerExtractor(Request request) {
    var token = request.headers['authorization'];
    if (token == null) {
      throw 'authorization is empty';
    }
    token = token.replaceFirst(RegExp(r'\w{6}'), '').trim();

    return token;
  }
}
