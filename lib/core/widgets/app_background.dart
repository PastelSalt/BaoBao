import 'package:baobao/app/theme/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A full-screen illustrated background from the catalogue, behind [child].
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.asset, required this.child});

  /// An SVG asset path.
  final String asset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.offWhite,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(child: SvgPicture.asset(asset, fit: BoxFit.cover)),
          child,
        ],
      ),
    );
  }
}
