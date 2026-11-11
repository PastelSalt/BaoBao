import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands a link (phone call, text message, web page) to the device.
abstract interface class LinkOpener {
  /// Returns false if nothing on the device could open [uri].
  Future<bool> open(Uri uri);
}

class UrlLauncherLinkOpener implements LinkOpener {
  const UrlLauncherLinkOpener();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

final linkOpenerProvider = Provider<LinkOpener>((ref) => const UrlLauncherLinkOpener());
