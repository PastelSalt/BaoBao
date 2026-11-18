import 'package:baobao/app/theme/app_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// BaoBao's interface icons, drawn in one style (see `tool/make_ui_icons.py`).
enum Glyph {
  back,
  close,
  add,
  check,
  settings,
  help,
  shop,
  claw,
  sparkle,
  cheer,
  heart,
  music,
  play,
  stop,
  call,
  text,
  web,
  lock,
  unlock,
  delete,
  edit,
  person,
  swap,
  info,
  document,
  tour,
  alert,
  chart,
  volume;

  String get asset => 'assets/images/icons/$name.svg';
}

/// An icon, tinted with the current text colour unless [color] is given.
/// Icons are decoration: the control around them carries the label.
class AppIcon extends StatelessWidget {
  const AppIcon(this.glyph, {super.key, this.size = 24, this.color});

  final Glyph glyph;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? DefaultTextStyle.of(context).style.color ?? context.palette.ink;
    return ExcludeSemantics(
      child: SvgPicture.asset(
        glyph.asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      ),
    );
  }
}
