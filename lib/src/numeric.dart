import 'interface.dart';

@pragma('vm:entry-point')
num? getNumber(dynamic arg) {
  if (arg is num) {
    return arg;
  } else if (arg is String) {
    try {
      return double.parse(arg);
    } on FormatException {
      return null;
    }
  }
  return null;
}

@pragma('vm:entry-point')
dynamic binaryOperate(dynamic Function(num n1, num n2) op, Applier applier,
    dynamic data, List params) {
  if (params.length <= 1) {
    return null;
  }

  var v1 = applier(params[0], data);
  var v2 = applier(params[1], data);

  var n1 = getNumber(v1);
  var n2 = getNumber(v2);
  if (n1 == null || n2 == null) {
    return null;
  }
  return op(n1, n2);
}

@pragma('vm:entry-point')
dynamic reduceOperate(num Function(num n1, num n2) op, Applier applier,
    dynamic data, List params, num zero) {
  var r = zero;
  for (var p in params) {
    var v = applier(p, data);
    var n = getNumber(v);
    if (n == null) {
      return null;
    }
    r = op(r, n);
    if (r.isNaN) {
      break;
    }
  }
  return r;
}

@pragma('vm:entry-point')
dynamic addOperator(Applier applier, dynamic data, List params) {
  return reduceOperate((a, b) => a + b, applier, data, params, 0.0);
}

@pragma('vm:entry-point')
dynamic mulOperator(Applier applier, dynamic data, List params) {
  return reduceOperate((a, b) => a * b, applier, data, params, 1.0);
}

@pragma('vm:entry-point')
dynamic subOperator(Applier applier, dynamic data, List params) {
  if (params.length == 1) {
    var v = applier(params[0], data);
    var n = getNumber(v);
    if (n == null) {
      return null;
    }
    return -n;
  }
  return binaryOperate((a, b) => a - b, applier, data, params);
}

@pragma('vm:entry-point')
dynamic divOperator(Applier applier, dynamic data, List params) {
  return binaryOperate((a, b) => a / b, applier, data, params);
}

@pragma('vm:entry-point')
dynamic modOperator(Applier applier, dynamic data, List params) {
  return binaryOperate((a, b) => a % b, applier, data, params);
}

@pragma('vm:entry-point')
dynamic greaterOperator(Applier applier, dynamic data, List params) {
  var r = reduceOperate(
      (a, b) => a > b ? b : double.nan, applier, data, params, double.infinity);
  if (r == null) return false;
  return !r.isNaN;
}

@pragma('vm:entry-point')
dynamic greaterEqualOperator(Applier applier, dynamic data, List params) {
  var r = reduceOperate((a, b) => a >= b ? b : double.nan, applier, data,
      params, double.infinity);
  if (r == null) return false;
  return !r.isNaN;
}

@pragma('vm:entry-point')
dynamic lessOperator(Applier applier, dynamic data, List params) {
  var r = reduceOperate((a, b) => a < b ? b : double.nan, applier, data, params,
      -double.infinity);
  if (r == null) return false;
  return !r.isNaN;
}

@pragma('vm:entry-point')
dynamic lessEqualOperator(Applier applier, dynamic data, List params) {
  var r = reduceOperate((a, b) => a <= b ? b : double.nan, applier, data,
      params, -double.infinity);
  if (r == null) return false;
  return !r.isNaN;
}

@pragma('vm:entry-point')
dynamic maxOperator(Applier applier, dynamic data, List params) {
  return reduceOperate(
      (a, b) => a > b ? a : b, applier, data, params, -double.infinity);
}

@pragma('vm:entry-point')
dynamic minOperator(Applier applier, dynamic data, List params) {
  return reduceOperate(
      (a, b) => a < b ? a : b, applier, data, params, double.infinity);
}
