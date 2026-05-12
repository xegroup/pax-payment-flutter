import 'package:flutter/material.dart';

/// Global route observer for [RouteAware] widgets (e.g. HomeTab refresh).
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
