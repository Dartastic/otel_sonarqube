// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_sonarqube_suppression.dart';

class SonarQubeResult {
  const SonarQubeResult({
    this.organization,
    this.projectKey,
    this.branch,
    this.qualityGate,
    this.qualityGateStatus,
    this.bugs,
    this.vulnerabilities,
    this.codeSmells,
    this.hotspots,
    this.coverage,
    this.duplications,
    this.linesOfCode,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? organization;
  final String? projectKey;
  final String? branch;
  final String? qualityGate;
  final String? qualityGateStatus;
  final int? bugs;
  final int? vulnerabilities;
  final int? codeSmells;
  final int? hotspots;
  final double? coverage;
  final double? duplications;
  final int? linesOfCode;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class SonarQubeCallResult<T> {
  const SonarQubeCallResult({required this.value, this.result});
  final T value;
  final SonarQubeResult? result;
}

Future<T> tracedSonarQube<T>({
  required String operation,
  required Future<SonarQubeCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (sonarQubeInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_sonarqube');
  final span = t.startSpan('sonarqube $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'sonarqube');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.organization != null) {
        span.setStringAttribute('sonarqube.organization', res.organization!);
      }
      if (res.projectKey != null) {
        span.setStringAttribute('sonarqube.project.key', res.projectKey!);
      }
      if (res.branch != null) {
        span.setStringAttribute('vcs.ref.head.name', res.branch!);
      }
      if (res.qualityGate != null) {
        span.setStringAttribute('sonarqube.quality_gate', res.qualityGate!);
      }
      if (res.qualityGateStatus != null) {
        span.setStringAttribute(
          'sonarqube.quality_gate.status',
          res.qualityGateStatus!,
        );
      }
      if (res.bugs != null) {
        span.setIntAttribute('sonarqube.bugs', res.bugs!);
      }
      if (res.vulnerabilities != null) {
        span.setIntAttribute('sonarqube.vulnerabilities', res.vulnerabilities!);
      }
      if (res.codeSmells != null) {
        span.setIntAttribute('sonarqube.code_smells', res.codeSmells!);
      }
      if (res.hotspots != null) {
        span.setIntAttribute('sonarqube.hotspots', res.hotspots!);
      }
      if (res.coverage != null) {
        span.setDoubleAttribute('sonarqube.coverage', res.coverage!);
      }
      if (res.duplications != null) {
        span.setDoubleAttribute('sonarqube.duplications', res.duplications!);
      }
      if (res.linesOfCode != null) {
        span.setIntAttribute('sonarqube.loc', res.linesOfCode!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('sonarqube.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'sonarqube.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
