// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_sonarqube_suppression.dart';

class SonarQubeResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class SonarQubeCallResult<T> {
  /// Creates a call result.
  const SonarQubeCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final SonarQubeResult? result;
}

Future<T> tracedSonarQube<T>({
  required String operation,
  required Future<SonarQubeCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (sonarQubeInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_sonarqube');
  final span = t.startSpan('sonarqube $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'sonarqube')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.organization != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('sonarqube.organization', res.organization!)
        ]));
      }
      if (res.projectKey != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('sonarqube.project.key', res.projectKey!)
        ]));
      }
      if (res.branch != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('vcs.ref.head.name', res.branch!)]));
      }
      if (res.qualityGate != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('sonarqube.quality_gate', res.qualityGate!)
        ]));
      }
      if (res.qualityGateStatus != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'sonarqube.quality_gate.status',
            res.qualityGateStatus!,
          )
        ]));
      }
      if (res.bugs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('sonarqube.bugs', res.bugs!)]));
      }
      if (res.vulnerabilities != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt(
              'sonarqube.vulnerabilities', res.vulnerabilities!)
        ]));
      }
      if (res.codeSmells != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('sonarqube.code_smells', res.codeSmells!)]));
      }
      if (res.hotspots != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('sonarqube.hotspots', res.hotspots!)]));
      }
      if (res.coverage != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('sonarqube.coverage', res.coverage!)]));
      }
      if (res.duplications != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeDouble('sonarqube.duplications', res.duplications!)
        ]));
      }
      if (res.linesOfCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('sonarqube.loc', res.linesOfCode!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('sonarqube.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'sonarqube.error',
          )
        ]));
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
