import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformWidget<M extends Widget, C extends Widget> extends StatelessWidget {
  const PlatformWidget({super.key});

  M buildMaterialWidget(BuildContext context);
  C buildCupertinoWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return buildMaterialWidget(context);
    }
    
    // For manual testing/forcing iOS look on desktop if needed
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS) {
      return buildCupertinoWidget(context);
    }
    
    return buildMaterialWidget(context);
  }
}
