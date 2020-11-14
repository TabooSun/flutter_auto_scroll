import 'package:flutter/material.dart';

/// This widget is used to scroll when the [Draggable] reaches view
/// boundary.
class DraggableAutoScroll extends StatefulWidget {
  /// The [child] where the [Draggable] lives.
  final Widget child;

  /// The [scrollController] of the parent scrollable view.
  final ScrollController scrollController;

  /// The direction of the list scrolling.
  final Axis scrollDirection;

  /// When using with [LongPressDraggable], you might want to pass this to
  /// inform [DraggableAutoScroll] to start tracking.
  final bool startTracking;

  /// The constraints of the view that [Draggable] lives. This is typically
  /// retrieved from [LayoutBuilder].
  final BoxConstraints constraints;

  /// The height of the app bar. This is default to [kToolbarHeight].
  final double appBarHeight;

  DraggableAutoScroll({
    Key key,
    this.child,
    @required this.scrollController,
    @required this.scrollDirection,
    this.startTracking = true,
    @required this.constraints,
    this.appBarHeight = kToolbarHeight,
  })  : assert(scrollController != null),
        assert(constraints != null),
        assert(scrollDirection != null),
        super(key: key);

  @override
  _DraggableAutoScrollState createState() => _DraggableAutoScrollState();
}

class _DraggableAutoScrollState extends State<DraggableAutoScroll> {
  bool _isScrollingView = false;

  @override
  Widget build(BuildContext context) {
    final constraints = widget.constraints;
    final hasInfiniteWidth = constraints.hasInfiniteWidth;
    final hasInfiniteHeight = constraints.hasInfiniteHeight;

    final size = constraints.constrain(Size.infinite);
    final viewPortHeight = size.height;
    final viewPortWidth = size.width;

    final safeAreaOffset = MediaQuery.of(context).padding.top;
    return Listener(
      onPointerMove: (event) async {
        final scrollController = widget.scrollController;
        if (scrollController == null ||
            _isScrollingView ||
            !widget.startTracking) return;
        final normalizedDy =
            event.position.dy - widget.appBarHeight - safeAreaOffset;
        final dx = event.position.dx;

        Future<void> scrollToPosition(double offset) async {
          _isScrollingView = true;
          await widget.scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          _isScrollingView = false;
        }

        // Define how much to move when hitting boundary.

        const movementOffset = 96;

        if (widget.scrollDirection == Axis.horizontal) {
          // Check if we should scroll right.
          if (dx >= (viewPortWidth * 0.9)) {
            var offsetToMove = scrollController.offset + movementOffset;
            final maxScrollExtent = scrollController.position.maxScrollExtent;

            if (!hasInfiniteWidth)
              offsetToMove = scrollController.offset >= maxScrollExtent
                  ? maxScrollExtent
                  : offsetToMove;
            await scrollToPosition(offsetToMove);
          }

          // Check if we should scroll left.
          else if (dx <= (viewPortWidth * 0.1)) {
            var offsetToMove = scrollController.offset - movementOffset;
            offsetToMove = offsetToMove < 0 ? 0 : offsetToMove;
            await scrollToPosition(offsetToMove);
          }
        } else {
          // Check if we should scroll down.

          if (normalizedDy >= (viewPortHeight * 0.9)) {
            var offsetToMove = scrollController.offset + movementOffset;
            final maxScrollExtent = scrollController.position.maxScrollExtent;

            if (!hasInfiniteHeight)
              offsetToMove = scrollController.offset >= maxScrollExtent
                  ? maxScrollExtent
                  : offsetToMove;
            await scrollToPosition(offsetToMove);
          }
          // Check if we should scroll up.

          else if (normalizedDy <= (viewPortHeight * 0.1)) {
            var offsetToMove = scrollController.offset - movementOffset;
            offsetToMove = offsetToMove < 0 ? 0 : offsetToMove;
            await scrollToPosition(offsetToMove);
          }
        }
      },
      child: widget.child,
    );
  }
}
