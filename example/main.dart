// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_sonarqube/otel_sonarqube.dart';

/// Traces Sonarqube calls with OpenTelemetry.
///
/// `otel_sonarqube` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Sonarqube call in
/// [tracedSonarQube]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'sonarqube-example');

  // Traces a Sonarqube call.
  final sonarQubeId = await tracedSonarQube<String>(
    operation: 'create',
    invoke: () async {
      // Make the Sonarqube call here, then report what it returned.
      const id = 'sonarqube_8f3a2c';
      return const SonarQubeCallResult(
          value: id,
          result: SonarQubeResult(
              organization: 'example',
              projectKey: 'orders/2026/inv-1042.pdf',
              branch: 'example',
              qualityGate: 'example',
              qualityGateStatus: 'succeeded',
              bugs: 1,
              vulnerabilities: 1,
              codeSmells: 1,
              hotspots: 1,
              coverage: 0.5,
              duplications: 0.5,
              linesOfCode: 1,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedSonarQube create returned $sonarQubeId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutSonarQubeInstrumentationAsync.
  await runWithoutSonarQubeInstrumentationAsync(
    () => tracedSonarQube<String>(
      operation: 'create',
      invoke: () async {
        const id = 'sonarqube_8f3a2c';
        return const SonarQubeCallResult(
            value: id,
            result: SonarQubeResult(
                organization: 'example',
                projectKey: 'orders/2026/inv-1042.pdf',
                branch: 'example',
                qualityGate: 'example',
                qualityGateStatus: 'succeeded',
                bugs: 1,
                vulnerabilities: 1,
                codeSmells: 1,
                hotspots: 1,
                coverage: 0.5,
                duplications: 0.5,
                linesOfCode: 1,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
