import 'package:baobao/app/theme/app_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The asset to draw for a background, given the theme: each background has a
/// night version next to it (`bamboo.svg` and `bamboo_night.svg`).
String backgroundAssetFor(String asset, {required bool dark}) =>
    dark ? asset.replaceFirst(RegExp(r'\.svg$'), '_night.svg') : asset;

/// A full-screen illustrated background from the catalogue, behind [child].
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.asset, required this.child});

  /// The day version's SVG path.
  final String asset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ColoredBox(
      color: p.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: SvgPicture.asset(backgroundAssetFor(asset, dark: p.isDark), fit: BoxFit.cover),
          ),
          child,
        ],
      ),
    );
  }
}
