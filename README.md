# otel_sonarqube

Dartastic OpenTelemetry bridge for SonarQube / SonarCloud (code quality + security).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_sonarqube/otel_sonarqube.dart';

await tracedSonarQube<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return SonarQubeCallResult(value: r, result: SonarQubeResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutSonarQubeInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
