import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Provides image upload and URL transformation via ImageKit.io.
///
/// Replace the three constants below with your own credentials from
/// https://imagekit.io/dashboard/developer/api-keys
///
/// The [isConfigured] getter returns false when the placeholders are still in
/// place; the upload method returns null in that case so callers can degrade
/// gracefully without crashing.
class ImageKitService {
  // ── Replace these with your real ImageKit credentials ──────────────────────
  static const _privateKey = 'YOUR_IMAGEKIT_PRIVATE_KEY';
  static const _publicKey = 'YOUR_IMAGEKIT_PUBLIC_KEY';
  static const _urlEndpoint = 'YOUR_IMAGEKIT_URL_ENDPOINT'; // e.g. https://ik.imagekit.io/yourId
  // ───────────────────────────────────────────────────────────────────────────

  static const _uploadEndpoint =
      'https://upload.imagekit.io/api/v1/files/upload';

  /// Returns true only when all three constants have been replaced.
  static bool get isConfigured =>
      !_privateKey.startsWith('YOUR_') &&
      !_publicKey.startsWith('YOUR_') &&
      !_urlEndpoint.startsWith('YOUR_');

  // ── Upload ──────────────────────────────────────────────────────────────────

  /// Uploads [imageFile] to ImageKit and returns the public URL.
  /// Returns null when not configured or on any error.
  static Future<String?> uploadImage(File imageFile, String fileName) async {
    if (!isConfigured) return null;
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Auth = base64Encode(utf8.encode('$_privateKey:'));

      final request =
          http.MultipartRequest('POST', Uri.parse(_uploadEndpoint))
            ..headers['Authorization'] = 'Basic $base64Auth'
            ..fields['publicKey'] = _publicKey
            ..fields['fileName'] = fileName
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: fileName),
            );

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return json['url'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── URL Transformation ──────────────────────────────────────────────────────

  /// Returns an ImageKit URL with optional resize transformations.
  /// [imagePath] is the path relative to your ImageKit media library.
  static String getUrl(String imagePath, {int? width, int? height}) {
    final transforms = <String>[
      if (width != null) 'w-$width',
      if (height != null) 'h-$height',
    ];
    if (transforms.isEmpty) return '$_urlEndpoint/$imagePath';
    return '$_urlEndpoint/tr:${transforms.join(',')}/$imagePath';
  }

  /// Returns a full remote URL if [url] is already absolute, or builds one.
  static String resolveUrl(String url, {int? width, int? height}) {
    if (url.startsWith('http')) {
      if (width == null && height == null) return url;
      // Inject ImageKit transformation into an existing absolute URL
      final transforms = [
        if (width != null) 'w-$width',
        if (height != null) 'h-$height',
      ].join(',');
      // Insert /tr:../ before the path portion
      final uri = Uri.parse(url);
      final newPath = '/tr:$transforms${uri.path}';
      return uri.replace(path: newPath).toString();
    }
    return getUrl(url, width: width, height: height);
  }
}
