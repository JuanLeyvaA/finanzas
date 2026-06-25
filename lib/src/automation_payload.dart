String? extractAutomationText(Uri uri) {
  for (final key in const ['text', 'payload', 'message', 'raw']) {
    final value = uri.queryParameters[key]?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

Uri buildAutomationUri({
  required Uri baseUri,
  required String text,
}) {
  return baseUri.replace(queryParameters: <String, String>{
    ...baseUri.queryParameters,
    'text': text,
  });
}
