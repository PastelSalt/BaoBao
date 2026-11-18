import 'package:baobao/app/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the whole app to take care of the phone's own chrome:
///
/// - draws behind the status and navigation bars, with icons that stay
///   readable in light and dark themes;
/// - keeps phones in portrait (BaoBao's art and the claw machine are portrait)
///   while letting tablets rotate.
class SystemChromePolicy extends StatefulWidget {
  const SystemChromePolicy({super.key, required this.child});

  final Widget child;

  /// Screens whose shorter side is at least this many logical pixels are
  /// treated as tablets.
  static const tabletShortestSide = 600.0;

  @override
  State<SystemChromePolicy> createState() => _SystemChromePolicyState();
}

class _SystemChromePolicyState extends State<SystemChromePolicy> {
  bool? _tablet;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).ignore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tablet = MediaQuery.sizeOf(context).shortestSide >= SystemChromePolicy.tabletShortestSide;
    if (tablet == _tablet) return;
    _tablet = tablet;
    SystemChrome.setPreferredOrientations(
      tablet
          ? DeviceOrientation.values
          : const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    ).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final icons = dark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: icons,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: icons,
        systemNavigationBarContrastEnforced: false,
      ),
      child: widget.child,
    );
  }
}

/// Used by tests: whether a width counts as a tablet.
bool isTablet(Size size) => size.shortestSide >= SystemChromePolicy.tabletShortestSide;

/// The width of the content column on any screen.
double contentWidthFor(double screenWidth) => screenWidth.clamp(0.0, Sizes.contentWidth);
