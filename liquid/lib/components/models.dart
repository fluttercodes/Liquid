part of 'components.dart';

class LModelDialog extends StatelessWidget {
  final LModelHeader header;
  final LModelBody body;
  final LModelFooter footer;

  const LModelDialog({
    Key key,
    this.header,
    this.body,
    this.footer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          header ?? Container(),
          body ?? Container(),
          footer ?? Container(),
        ],
      ),
    );
  }
}

class LModelFooter extends StatelessWidget {
  final List<Widget> actions;
  final EdgeInsets padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showSeperator;

  const LModelFooter({
    Key key,
    this.actions = const [],
    this.padding = const EdgeInsets.all(12.0),
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.showSeperator = true,
  })  : assert(actions != null),
        assert(padding != null),
        assert(showSeperator != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          top: showSeperator
              ? BorderSide(color: Colors.black12)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.end,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: actions,
      ),
    );
  }
}

class LModelBody extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const LModelBody({
    Key key,
    @required this.child,
    this.padding = const EdgeInsets.all(16.0),
  })  : assert(child != null),
        assert(padding != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class LModelHeader extends StatelessWidget {
  final String title;
  final Function onClose;
  final EdgeInsets padding;
  final bool showSeperator;

  const LModelHeader({
    Key key,
    @required this.title,
    this.onClose,
    this.padding = const EdgeInsets.all(16.0),
    this.showSeperator = true,
  })  : assert(title != null),
        assert(padding != null),
        assert(showSeperator != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LiquidTheme.of(context).typographyTheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: showSeperator
              ? BorderSide(color: Colors.black12)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(title, style: theme.h5),
          Material(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white,
            child: LIconButton(
              icon: Icon(Icons.close),
              onPressed: () => _close(context),
              splashThickness: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _close(BuildContext context) async {
    await LiquidStateManager.of(context).popModel();
    if (onClose != null) onClose();
  }
}

class LModel extends StatelessWidget {
  final LModelHeader header;
  final LModelBody body;
  final LModelFooter footer;
  final EdgeInsets margin;
  final MainAxisAlignment positon;
  final bool expand;

  // expand need to be true to use width
  final double width;

  LModel({
    Key key,
    this.header,
    this.body,
    this.footer,
    this.margin,
    this.positon,
    this.expand,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: positon ?? MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: (expand ?? false) ? width : 498.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: Colors.black12),
            ),
            margin: margin ?? const EdgeInsets.all(10.0),
            child: LModelDialog(
              header: header,
              body: body,
              footer: footer,
            ),
          ),
        ],
      ),
    );
  }
}

class LAnimatedModel extends StatefulWidget {
  final LModel model;
  final Tween<Offset> positionTween;
  final bool barrierDismissable;
  final Color backdropColor;

  const LAnimatedModel({
    Key key,
    @required this.model,
    this.positionTween,
    this.barrierDismissable,
    this.backdropColor,
  })  : assert(model != null),
        super(key: key);

  @override
  _LAnimatedModelState createState() => _LAnimatedModelState();

  static _LAnimatedModelState of(BuildContext context) {
    final _LAnimatedModelState animator =
        context.findAncestorStateOfType<_LAnimatedModelState>();

    return animator;
  }
}

class _LAnimatedModelState extends State<LAnimatedModel>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    final size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.ease,
        ),
      ),
      child: Material(
        color: widget.backdropColor ?? Colors.black54,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height,
            ),
            child: GestureDetector(
              onTap: widget.barrierDismissable
                  ? () async => await LiquidStateManager.of(context).popModel()
                  : null,
              child: SlideTransition(
                position: (widget.positionTween ??
                        Tween(begin: Offset(0.0, -10.0), end: Offset.zero))
                    .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.fastLinearToSlowEaseIn,
                  ),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: GestureDetector(
                    onTap: () {}, // to prevent accidental closing
                    child: widget.model,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> close() async => await _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ModelHandler extends LOverlayManager {
  ModelHandler(OverlayEntry entry, GlobalKey<_LAnimatedModelState> key)
      : super(entry, key);

  @override
  Future<void> close() async {
    await (key as GlobalKey<_LAnimatedModelState>).currentState.close();
    entry.remove();
  }
}

void showLModel(
  BuildContext context, {
  @required LModel Function(BuildContext context) builder,
  Tween<Offset> positionTween,
  Color backdropColor,
  bool barrierDismissable,
}) {
  final overlay = Overlay.of(context);
  final GlobalKey<_LAnimatedModelState> key = GlobalKey<_LAnimatedModelState>();
  final model = OverlayEntry(
    builder: (context) => LAnimatedModel(
      key: key,
      model: builder(context),
      positionTween: positionTween,
      barrierDismissable: barrierDismissable,
      backdropColor: backdropColor,
    ),
  );
  overlay.insert(model);
  final _manager = ModelHandler(
    model,
    key,
  );
  LiquidStateManager.of(context).pushModel(_manager);
}
