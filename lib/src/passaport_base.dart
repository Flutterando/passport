import 'dart:async';

import 'package:shelf/shelf.dart';

class Passport {
  final Map<String, Strategy> _strategies = {};

  void use(Strategy strategy, {String? name}) {
    if (_strategies.containsKey(name)) {
      throw 'Strategy \'$name\' registered';
    }

    _strategies[name ?? strategy.name] = strategy;
  }

  Middleware authorization(String strategyName, {Map<String, dynamic> options = const {}}) {
    final strategy = _strategies[strategyName];
    if (strategy == null) {
      throw 'Strategy \'$strategyName\' not registered';
    }
    return (innerHandler) {
      return (request) {
        return strategy.execute(request, options, innerHandler);
      };
    };
  }
}

abstract class Strategy {
  final String name;

  Strategy(this.name);

  FutureOr<Response> execute(Request request, Map<String, dynamic> options, Handler next);
}
