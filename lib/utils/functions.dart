import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math.dart';

_exponent(double val) => pow(sin(val / 2), 2);

class Functions {
  static double haversine(LatLng deviceCoordinate, LatLng targetCoordinate) {
    double r = 6371;
    double latRadian =
        radians(targetCoordinate.latitude - deviceCoordinate.latitude);
    double lonRadian =
        radians(targetCoordinate.longitude - deviceCoordinate.longitude);
    double a = _exponent(latRadian) +
        cos(deviceCoordinate.latitude) *
            cos(targetCoordinate.latitude) *
            _exponent(lonRadian);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanceInKilometer = r * c;
    double distanceInMeter = distanceInKilometer * 1000;

    return distanceInMeter;
  }
}
