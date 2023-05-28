import 'package:boxorders/dto/box_dto.dart';
import 'package:easy_localization/easy_localization.dart' as l10n;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BoxItem extends StatefulWidget {
  final BoxDto child;

  const BoxItem({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<BoxItem> createState() => _BoxItemState();
}

class _BoxItemState extends State<BoxItem> {
  bool isExpanded = false;
  bool hasOverflow = true;
  static const _duration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void toggleExpand() => setState(() => isExpanded = true);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: widget.child.image.animate().fadeIn(duration: 400.ms),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectionArea(
                  child: Text(
                    widget.child.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (widget.child.description.isNotEmpty)
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      // Use a textpainter to determine if it will exceed max lines
                      var painter = TextPainter(
                        maxLines: 4,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        text: TextSpan(text: widget.child.description),
                      );

                      // trigger it to layout
                      painter.layout(maxWidth: constraints.maxWidth);

                      hasOverflow = painter.didExceedMaxLines;
                      // if text wasn't overflown
                      if (!painter.didExceedMaxLines) {
                        return Text(widget.child.description);
                      }

                      return AnimatedCrossFade(
                        duration: _duration,
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstCurve: Curves.easeIn,
                        secondCurve: Curves.easeOut,
                        firstChild: SelectionArea(
                          child: Text(
                            widget.child.description,
                            maxLines: 4,
                          ),
                        ),
                        secondChild: SelectionArea(
                          child: Text(widget.child.description),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton.tonal(
                          onPressed: () {},
                          child: Text(
                              '${widget.child.price} ${'globals.currency'.tr()}')),
                      if (hasOverflow)
                        TextButton(
                          onPressed: toggleExpand,
                          child: Text('post.showMore'.tr()),
                        ).animate(target: isExpanded ? 1 : 0).scaleY(
                              begin: 1,
                              end: 0,
                              duration: _duration,
                              alignment: Alignment.bottomCenter,
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
