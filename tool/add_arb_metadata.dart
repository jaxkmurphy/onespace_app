import 'dart:convert';
import 'dart:io';

void main() {
  const paths = [
    'lib/l10n/app_en.arb',
    'lib/l10n/app_ga.arb',
  ];

  for (final path in paths) {
    final file = File(path);
    final source =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final output = <String, dynamic>{};

    for (final entry in source.entries) {
      if (entry.key.startsWith('@@')) {
        output[entry.key] = entry.value;
      }
    }

    for (final entry in source.entries) {
      final key = entry.key;

      if (key.startsWith('@')) continue;

      output[key] = entry.value;

      final existingMetadata = source['@$key'];
      final metadata = existingMetadata is Map
          ? Map<String, dynamic>.from(existingMetadata)
          : <String, dynamic>{};

      metadata.putIfAbsent(
        'description',
        () => 'Text used in the app for ${_readableName(key)}.',
      );

      output['@$key'] = metadata;
    }

    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync('${encoder.convert(output)}\n');

    print('Metadata updated: $path');
  }
}

String _readableName(String key) {
  return key
      .replaceAll('_', ' ')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .toLowerCase();
}