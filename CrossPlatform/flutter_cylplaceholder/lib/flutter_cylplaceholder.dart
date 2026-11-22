/// CYLTableViewPlaceHolder for Flutter: a placeholder item (an animation or image with a title) that calls
/// CYLTabBarController's `CYLAnimationView` directly. Playback names are upstream's (`animationSpeed`, `animationLoops`,
/// `animationRestartToken`, `CYLAnimationController.restart()`); there is no engine logic or native code here.
library;

export 'package:flutter_cyltabbar/flutter_cyltabbar.dart' show CYLAnimationView, CYLAnimationController, animationURLWithOptions;
export 'src/cyl_placeholder_item.dart';
