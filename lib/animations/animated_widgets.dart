import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:food_scanner/animations/animation_constants.dart';

/// A widget that animates its child when it is first built
class AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final List<Effect> effects;
  final bool enabled;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.effects = const [],
    this.enabled = true,
  });

  factory AnimatedEntrance.fadeIn({
    Key? key,
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedEntrance(
      key: key,
      effects: [AnimationConstants.fadeIn],
      enabled: enabled,
      child: child,
    );
  }

  factory AnimatedEntrance.fadeInUp({
    Key? key,
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedEntrance(
      key: key,
      effects: AnimationConstants.fadeInUp,
      enabled: enabled,
      child: child,
    );
  }

  factory AnimatedEntrance.fadeInDown({
    Key? key,
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedEntrance(
      key: key,
      effects: AnimationConstants.fadeInDown,
      enabled: enabled,
      child: child,
    );
  }

  factory AnimatedEntrance.fadeInLeft({
    Key? key,
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedEntrance(
      key: key,
      effects: AnimationConstants.fadeInLeft,
      enabled: enabled,
      child: child,
    );
  }

  factory AnimatedEntrance.fadeInRight({
    Key? key,
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedEntrance(
      key: key,
      effects: AnimationConstants.fadeInRight,
      enabled: enabled,
      child: child,
    );
  }

  factory AnimatedEntrance.popIn({
    Key? key,
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedEntrance(
      key: key,
      effects: AnimationConstants.popIn,
      enabled: enabled,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return child.animate(effects: effects);
  }
}

/// A widget that animates a button when pressed
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double elevation;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 2,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
        }
      },
      child: Material(
        color: widget.color ?? theme.colorScheme.primary,
        borderRadius: widget.borderRadius,
        elevation: _isPressed ? 0 : widget.elevation,
        child: AnimatedContainer(
          duration: AnimationConstants.ultraFast,
          padding: widget.padding,
          decoration: BoxDecoration(borderRadius: widget.borderRadius),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A widget that animates a list of items with staggered animations
class AnimatedList extends StatelessWidget {
  final List<Widget> children;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Duration? delay;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Axis direction;
  final bool animateOnlyOnce;

  const AnimatedList.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.delay,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.controller,
    this.direction = Axis.vertical,
    this.animateOnlyOnce = false,
  }) : children = const [];

  const AnimatedList({
    super.key,
    required this.children,
    this.delay,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.controller,
    this.direction = Axis.vertical,
    this.animateOnlyOnce = false,
  }) : itemCount = 0,
       itemBuilder = _dummyItemBuilder;

  static Widget _dummyItemBuilder(BuildContext context, int index) =>
      const SizedBox();

  @override
  Widget build(BuildContext context) {
    final listView =
        direction == Axis.vertical
            ? _buildVerticalList()
            : _buildHorizontalList();

    if (animateOnlyOnce) {
      return listView;
    }

    return AnimationLimiter(child: listView);
  }

  Widget _buildVerticalList() {
    if (children.isNotEmpty) {
      return ListView(
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        controller: controller,
        children: List.generate(
          children.length,
          (index) => AnimationConfiguration.staggeredList(
            position: index,
            delay: delay ?? const Duration(milliseconds: 100),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: children[index]),
            ),
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: itemCount,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        controller: controller,
        itemBuilder:
            (context, index) => AnimationConfiguration.staggeredList(
              position: index,
              delay: delay ?? const Duration(milliseconds: 100),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: itemBuilder(context, index)),
              ),
            ),
      );
    }
  }

  Widget _buildHorizontalList() {
    if (children.isNotEmpty) {
      return ListView(
        scrollDirection: Axis.horizontal,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        controller: controller,
        children: List.generate(
          children.length,
          (index) => AnimationConfiguration.staggeredList(
            position: index,
            delay: delay ?? const Duration(milliseconds: 100),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: children[index]),
            ),
          ),
        ),
      );
    } else {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        controller: controller,
        itemBuilder:
            (context, index) => AnimationConfiguration.staggeredList(
              position: index,
              delay: delay ?? const Duration(milliseconds: 100),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: itemBuilder(context, index)),
              ),
            ),
      );
    }
  }
}

/// A widget that adds a pulsing animation to its child
class PulseAnimation extends StatelessWidget {
  final Widget child;
  final bool animate;

  const PulseAnimation({super.key, required this.child, this.animate = true});

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return child.animate(effects: AnimationConstants.pulseAnimation);
  }
}

/// A widget that animates its child when it becomes visible in the viewport
class AnimateOnVisible extends StatefulWidget {
  final Widget child;
  final List<Effect> effects;
  final bool once;

  const AnimateOnVisible({
    super.key,
    required this.child,
    this.effects = const [],
    this.once = true,
  });

  factory AnimateOnVisible.fadeIn({
    Key? key,
    required Widget child,
    bool once = true,
  }) {
    return AnimateOnVisible(
      key: key,
      effects: [AnimationConstants.fadeIn],
      once: once,
      child: child,
    );
  }

  factory AnimateOnVisible.fadeInUp({
    Key? key,
    required Widget child,
    bool once = true,
  }) {
    return AnimateOnVisible(
      key: key,
      effects: AnimationConstants.fadeInUp,
      once: once,
      child: child,
    );
  }

  @override
  State<AnimateOnVisible> createState() => _AnimateOnVisibleState();
}

class _AnimateOnVisibleState extends State<AnimateOnVisible> {
  bool _isVisible = false;
  bool _hasAnimated = false;

  @override
  Widget build(BuildContext context) {
    if (widget.once && _hasAnimated) {
      return widget.child;
    }

    return VisibilityDetector(
      key: ValueKey(widget),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction > 0.1;
        if (isVisible != _isVisible) {
          setState(() {
            _isVisible = isVisible;
            if (isVisible) {
              _hasAnimated = true;
            }
          });
        }
      },
      child:
          _isVisible
              ? widget.child.animate(effects: widget.effects)
              : widget.child.animate(effects: [FadeEffect(begin: 0, end: 0)]),
    );
  }
}

/// A widget for custom visibility detection
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(VisibilityInfo) onVisibilityChanged;
  @override
  final Key key;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector>
    with WidgetsBindingObserver {
  final GlobalKey _widgetKey = GlobalKey();
  bool _isVisibilityCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scheduleVisibilityCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleVisibilityCheck();
  }

  void _scheduleVisibilityCheck() {
    if (!_isVisibilityCheckScheduled) {
      _isVisibilityCheckScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isVisibilityCheckScheduled = false;
        _checkVisibility();
      });
    }
  }

  void _checkVisibility() {
    final renderObject = _widgetKey.currentContext?.findRenderObject();
    final viewportRenderObject = _findViewport();

    if (renderObject == null || viewportRenderObject == null) {
      widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 0.0));
      return;
    }

    final widgetBox = renderObject.paintBounds;
    final viewportBox = viewportRenderObject.paintBounds;

    final widgetOffset = _getGlobalOffset(renderObject);
    final viewportOffset = _getGlobalOffset(viewportRenderObject);

    final relativeRect = Rect.fromLTWH(
      widgetOffset.dx - viewportOffset.dx,
      widgetOffset.dy - viewportOffset.dy,
      widgetBox.width,
      widgetBox.height,
    );

    final intersectionRect = relativeRect.intersect(viewportBox);
    if (intersectionRect.isEmpty) {
      widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 0.0));
      return;
    }

    final visibleArea = intersectionRect.width * intersectionRect.height;
    final widgetArea = widgetBox.width * widgetBox.height;
    final visibleFraction = visibleArea / widgetArea;

    widget.onVisibilityChanged(
      VisibilityInfo(visibleFraction: visibleFraction),
    );
  }

  RenderObject? _findViewport() {
    RenderObject? current = context.findRenderObject();
    while (current != null) {
      if (current is RenderBox && current.hasSize) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  Offset _getGlobalOffset(RenderObject renderObject) {
    if (renderObject is! RenderBox) {
      return Offset.zero;
    }

    try {
      return renderObject.localToGlobal(Offset.zero);
    } catch (_) {
      return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _widgetKey, child: widget.child);
  }
}

class VisibilityInfo {
  final double visibleFraction;

  const VisibilityInfo({required this.visibleFraction});
}
