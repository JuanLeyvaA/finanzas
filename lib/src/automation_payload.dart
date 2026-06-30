String? extractAutomationText(Uri uri) {
  for (final key in const [
    'text',
    'payload',
    'message',
    'raw',
    'clipboard',
    'content'
  ]) {
    final value = uri.queryParameters[key]?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

Uri buildAutomationUri({
  required String text,
}) {
  return Uri(
    scheme: 'misfin',
    host: 'import',
    queryParameters: <String, String>{
      'text': text,
    },
  );
}
