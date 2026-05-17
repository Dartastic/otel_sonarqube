// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_sonarqube/otel_sonarqube.dart';
import 'package:test/test.dart';

void main() {
  group('otel_sonarqube', () {
    test('suppression toggles in zone', () async {
      expect(sonarQubeInstrumentationSuppressed(), isFalse);
      await runWithoutSonarQubeInstrumentationAsync(() async {
        expect(sonarQubeInstrumentationSuppressed(), isTrue);
      });
      expect(sonarQubeInstrumentationSuppressed(), isFalse);
    });

    test('SonarQubeResult fields default null', () {
      const r = SonarQubeResult();
      expect(r.statusCode, isNull);
    });
  });
}
