import 'package:flutter/material.dart';

class CustomAppScroll extends StatefulWidget {
  const CustomAppScroll({
    required this.children,
    this.horizontalPadding = 24,
    super.key,
  });

  final List<Widget> children;
  final double horizontalPadding;

  @override
  State<CustomAppScroll> createState() => _CustomAppScrollState();
}

class _CustomAppScrollState extends State<CustomAppScroll> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentKey = GlobalKey();

  bool _exceedsHeight = false;

  void _checkIfExceedsHeight(BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? contentBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (contentBox != null) {
        final double contentHeight = contentBox.size.height;
        final double maxHeight = constraints.maxHeight;
        final bool newValue = contentHeight > maxHeight;
        if (newValue != _exceedsHeight) {
          setState(() {
            _exceedsHeight = newValue;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _checkIfExceedsHeight(constraints);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                if (_exceedsHeight)
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 8,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ),
                RawScrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 8.0,
                  trackVisibility: false,
                  thumbColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(right: _exceedsHeight ? 24 : 0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      child: Column(
                        key: _contentKey,
                        children: [...widget.children],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
