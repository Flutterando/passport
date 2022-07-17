import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../passaport.dart';

typedef LocalStrategyHandler = FutureOr<Response> Function(Request request, [dynamic user]);

class LocalStrategy extends Strategy {
  final FutureOr<Response> Function(Request request, LocalStrategyHandler next) verify;

  LocalStrategy(this.verify) : super('local');

  @override
  FutureOr<Response> execute(Request request, Map<String, dynamic> options, covariant LocalStrategyHandler next) {
    FutureOr<Response> _internalNext(Request request, [dynamic credential]) {
      return next(request, credential);
    }

    return verify(request, _internalNext);
  }

  static Map<String, dynamic> basicExtractor(Request request) {
    var credential = request.headers['authorization'];
    if (credential == null) {
      throw 'credentials is empty';
    }
    credential = credential.replaceFirst(RegExp(r'\w{5}'), '').trim();

    credential = String.fromCharCodes(base64Decode(credential));

    if (!RegExp(r'[\d\w]+:[\d\w]+').hasMatch(credential)) {
      throw 'credentials bad format';
    }

    final credentials = credential.split(':');
    return {'username': credentials.first, 'password': credentials.last};
  }
}
