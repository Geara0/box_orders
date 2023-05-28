import 'package:boxorders/dto/box_dto.dart';
import 'package:easy_localization/easy_localization.dart' as l10n;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BoxItemSmall extends StatefulWidget {
  final BoxDto child;
  final void Function() callback;

  const BoxItemSmall({
    required this.child,
    required this.callback,
    Key? key,
  }) : super(key: key);

  @override
  State<BoxItemSmall> createState() => _BoxItemSmallState();
}

class _BoxItemSmallState extends State<BoxItemSmall> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: widget.child.image.animate().fadeIn(duration: 400.ms),
          ),
          const SizedBox(width: 12),
          Column(
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
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.child.price} ${'globals.currency'.tr()}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          FilledButton(
            onPressed: widget.callback,
            child: Text('post.unsubscribe'.tr()),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
