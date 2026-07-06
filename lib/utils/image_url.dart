const Set<String> _invalidImageValues = {
  'null',
  'undefined',
  'none',
  'nil',
  'na',
  'n/a',
  '-',
};

bool hasUsableImageValue(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return false;
  }

  final lowerText = text.toLowerCase();
  if (_invalidImageValues.contains(lowerText)) {
    return false;
  }

  final uri = Uri.tryParse(text);
  final pathSegments = uri?.pathSegments
      .where((segment) => segment.trim().isNotEmpty)
      .toList();
  if (pathSegments != null && pathSegments.isNotEmpty) {
    final lastSegment = Uri.decodeComponent(pathSegments.last).toLowerCase();
    if (_invalidImageValues.contains(lastSegment)) {
      return false;
    }
  }

  return true;
}

String buildImageUrl({
  required String? baseUrl,
  required String folder,
  required Object? fileName,
}) {
  if (!hasUsableImageValue(baseUrl) || !hasUsableImageValue(fileName)) {
    return '';
  }

  final file = fileName.toString().trim();
  if (file.startsWith('http://') || file.startsWith('https://')) {
    return file;
  }

  final normalizedBase = baseUrl!.trim().endsWith('/')
      ? baseUrl.trim()
      : '${baseUrl.trim()}/';
  final cleanFolder = folder.trim().replaceAll(RegExp(r'^/+|/+$'), '');
  final cleanFile = file.replaceAll(RegExp(r'^/+'), '');

  if (cleanFolder.isEmpty) {
    return '$normalizedBase$cleanFile';
  }
  return '$normalizedBase$cleanFolder/$cleanFile';
}
