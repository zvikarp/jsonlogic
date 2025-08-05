import 'package:jsonlogic/src/datetime.dart';

import 'interface.dart';
import 'numeric.dart';
import 'truth.dart';
import 'string.dart';

@pragma('vm:entry-point')
dynamic ifOperator(Applier applier, dynamic data, List params) {
  while (true) {
    if (params.isEmpty) return null;
    if (params.length == 1) {
      return applier(params[0], data);
    }
    var cond = applier(params[0], data);
    if (truth(cond)) {
      return applier(params[1], data);
    } else if (params.length < 2) {
      return null;
    }
    params = params.sublist(2);
  }
}

bool isEqual(Applier applier, dynamic data, List params) {
  if (params.isEmpty) {
    return false;
  }
  if (params.length == 1) {
    return applier(params[0], data) == null;
  }
  var v1 = applier(params[0], data);
  var v2 = applier(params[1], data);

  if (v1 is List || v2 is List) {
    return compareContent(v1, v2);
  }

  if (getDateTime(v1) is DateTime) {
    return isDateTimeEqualOperator(applier, data, params);
  }

  if (v1 is String || v2 is String) {
    return toString(v1) == toString(v2);
  }
  if (v1 is bool || v2 is bool) {
    return truth(v1) == truth(v2);
  }
  return v1 == v2;
}

bool compareContent(dynamic first, dynamic second) {
  if (first is List && second is List) {
    return listEquals(first, second);
  } else if (first is List) {
    return listEquals(first, [second]);
  } else if (second is List) {
    return listEquals([first], second);
  }
  return false;
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

@pragma('vm:entry-point')
dynamic equalOperator(Applier applier, dynamic data, List params) {
  return isEqual(applier, data, params);
}

@pragma('vm:entry-point')
dynamic notEqualOperator(Applier applier, dynamic data, List params) {
  return !isEqual(applier, data, params);
}

@pragma('vm:entry-point')
dynamic strictEqualOperator(Applier applier, dynamic data, List params) {
  if (params.isEmpty) {
    return false;
  }
  if (params.length == 1) {
    return applier(params[0], data) == null;
  }
  var v1 = applier(params[0], data);
  var v2 = applier(params[1], data);
  return v1 == v2;
}

@pragma('vm:entry-point')
dynamic strictNEOperator(Applier applier, dynamic data, List params) {
  if (params.isEmpty) {
    return false;
  }
  if (params.length == 1) {
    return applier(params[0], data) != null;
  }
  var v1 = applier(params[0], data);
  var v2 = applier(params[1], data);
  return v1 != v2;
}

@pragma('vm:entry-point')
dynamic notOperator(Applier applier, dynamic data, List params) {
  if (params.isEmpty) {
    return false;
  }
  var v = applier(params[0], data);
  return !truth(v);
}

@pragma('vm:entry-point')
dynamic notNotOperator(Applier applier, dynamic data, List params) {
  if (params.isEmpty) {
    return false;
  }
  var v = applier(params[0], data);
  return truth(v);
}

@pragma('vm:entry-point')
dynamic orOperator(Applier applier, dynamic data, List params) {
  dynamic v;
  for (var p in params) {
    v = applier(p, data);
    if (truth(v)) return v;
  }
  return v;
}

@pragma('vm:entry-point')
dynamic andOperator(Applier applier, dynamic data, List params) {
  dynamic v;
  for (var p in params) {
    v = applier(p, data);
    if (!truth(v)) return v;
  }
  return v;
}

@pragma('vm:entry-point')
dynamic andBoolOperator(Applier applier, dynamic data, List params) {
  dynamic v;
  for (var p in params) {
    v = applier(p, data);
    if (!truth(v)) return false;
  }
  return true;
}

dynamic determineAndApplyComparison(Applier applier, dynamic data, List params,
    Function dateTimeOperator, Function numberOperator) {
  if (params.isEmpty) {
    return false;
  }

  var v1 = applier(params[0], data);
  if (getDateTime(v1) is DateTime) {
    return dateTimeOperator(applier, data, params);
  }

  return numberOperator(applier, data, params);
}

@pragma('vm:entry-point')
dynamic lessOperator(Applier applier, dynamic data, List params) {
  return determineAndApplyComparison(
      applier, data, params, dateTimeLessOperator, numLessOperator);
}

@pragma('vm:entry-point')
dynamic lessEqualOperator(Applier applier, dynamic data, List params) {
  return determineAndApplyComparison(
      applier, data, params, dateTimeLessEqualOperator, numLessEqualOperator);
}

@pragma('vm:entry-point')
dynamic greaterOperator(Applier applier, dynamic data, List params) {
  return determineAndApplyComparison(
      applier, data, params, dateTimeGreaterOperator, numGreaterOperator);
}

@pragma('vm:entry-point')
dynamic greaterEqualOperator(Applier applier, dynamic data, List params) {
  return determineAndApplyComparison(applier, data, params,
      dateTimeGreaterEqualOperator, numGreaterEqualOperator);
}
