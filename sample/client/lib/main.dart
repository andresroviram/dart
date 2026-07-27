import 'package:flutter/widgets.dart';

import 'src/app_rfwtxt.dart';

void main() {
  const baseUrl = String.fromEnvironment(
    'RFW_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  runApp(const RfwOnboardingApp(baseUrl: baseUrl));
}
