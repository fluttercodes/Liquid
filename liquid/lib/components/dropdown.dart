part of 'components.dart';

class _LDropdownItemRaw extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final Function onLongPress;
  final bool forText;
  final bool header;
  final EdgeInsets padding;
  final Color splashColor;
  final Color focusColor;
  final Color hoverColor;
  final Color highlightColor;
  final Color background;
  final TextStyle textStyle;
  final TextStyle disabledTextStyle;

  const _LDropdownItemRaw({
    Key key,
    @required this.child,
    @required this.forText,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.splashColor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.background,
    this.header,
    this.textStyle,
    this.disabledTextStyle,
  })  : assert(child != null),
        assert(forText != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LiquidTheme.of(context).dropdownTheme.itemTheme;

    return forText ? _buildForText(theme) : _buildForChild(theme);
  }

  Widget _buildForText(LiquidDropdownItemTheme theme) {
    if (header ?? false) {
      return AbsorbPointer(
        child: Material(
          color: background ?? Colors.transparent,
          textStyle: textStyle ?? theme.headerTextStyle,
          child: Padding(
            padding: padding ?? theme.headerPadding,
            child: child,
          ),
        ),
      );
    }

    return InkWell(
      canRequestFocus: true,
      splashColor: splashColor ?? theme.splashColor,
      focusColor: focusColor ?? theme.focusColor,
      hoverColor: hoverColor ?? theme.hoverColor,
      highlightColor: highlightColor ?? theme.highlightColor,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: background ?? Colors.transparent,
        textStyle: (onTap != null || onLongPress != null)
            ? textStyle ?? theme.textStyle
            : disabledTextStyle ?? theme.disabledTextStyle,
        child: Padding(
          padding: padding ?? theme.padding,
          child: child,
        ),
      ),
    );
  }

  Widget _buildForChild(LiquidDropdownItemTheme theme) {
    return Material(
      color: background ?? Colors.transparent,
      child: Padding(
        padding: padding ?? theme.padding,
        child: child,
      ),
    );
  }
}

class LDropdownItem extends _LDropdownItemRaw {
  LDropdownItem({
    Key key,
    Function onTap,
    @required String text,
    TextStyle style,
    TextStyle disabledStyle,
    Function onLongPress,
    EdgeInsets padding,
    Color splashColor,
    Color focusColor,
    Color hoverColor,
    Color highlightColor,
    Color background,
  }) : super(
          key: key,
          child: Text(text),
          textStyle: style,
          disabledTextStyle: disabledStyle,
          onTap: onTap,
          onLongPress: onLongPress,
          forText: true,
          padding: padding,
          splashColor: splashColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          background: background,
        );

  LDropdownItem.withChild({
    Key key,
    Widget child,
    EdgeInsets padding,
    Color background,
  }) : super(
          key: key,
          child: child,
          forText: false,
          padding: padding,
          background: background,
        );

  LDropdownItem.header({
    Key key,
    @required String text,
    TextStyle style,
    TextStyle disabledStyle,
    EdgeInsets padding,
    Color color = Colors.black45,
    Color background,
  }) : super(
          key: key,
          child: Text(text),
          textStyle: style,
          disabledTextStyle: disabledStyle,
          forText: true,
          header: true,
          padding: padding,
          background: background,
        );

  LDropdownItem.divider({
    Key key,
    double height,
    double thickness,
    double indent,
    double endIndent,
    Color color,
    Color background,
  }) : super(
          key: key,
          child: Divider(
            height: height,
            thickness: thickness,
            indent: indent,
            endIndent: endIndent,
            color: color,
          ),
          forText: false,
          padding: EdgeInsets.zero,
          background: background,
        );
}

class LDropdown extends StatefulWidget {
  final double hideOnTopOffset;
  final double predictiveHeight;
  final Widget trigger;
  final ShapeBorder shape;
  final EdgeInsets padding;
  final Color background;
  final double elevation;
  final List<LDropdownItem> items;
  final List<LDropdownItem> Function(BuildContext context) itemBuilder;
  final Color triggerSplashColor;
  final Color triggerFocusColor;
  final Color triggerHoverColor;
  final Color triggerHighlightColor;
  final ShapeBorder triggerShape;
  final bool scrollable;
  final bool scrollToClose;
  final Color backdrop;

  LDropdown({
    Key key,
    @required this.trigger,
    this.shape,
    this.padding,
    this.background,
    this.hideOnTopOffset = 50.0,
    this.predictiveHeight = 10.0,
    this.elevation,
    this.items,
    this.itemBuilder,
    this.triggerSplashColor,
    this.triggerFocusColor,
    this.triggerHoverColor,
    this.triggerHighlightColor,
    this.triggerShape,
    this.scrollable = false,
    this.scrollToClose = false,
    this.backdrop = Colors.black26,
  })  : assert(backdrop != null),
        assert(scrollable != null),
        assert(scrollToClose != null),
        assert(trigger != null),
        assert((scrollToClose && scrollable) || !scrollToClose,
            "for scrollToClose you need scrollable to be true"),
        assert(
            (items != null && itemBuilder == null) ||
                (items == null && itemBuilder != null),
            "need item or itembuilder for dropdown"),
        super(key: key);

  @override
  _LDropdownState createState() => _LDropdownState();
}

class _LDropdownState extends State<LDropdown> with WidgetsBindingObserver {
  GlobalKey _triggerKey;
  OverlayEntry _dropdown;
  bool _opened;
  ScrollPosition _position;
  Widget _dropdownContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _triggerKey = GlobalKey();
    _opened = false;
  }

  _setupDropdownItems() {
    final theme = LiquidTheme.of(context).dropdownTheme;

    _dropdownContent = GestureDetector(
      onTap: () {},
      child: Container(
        child: Material(
          color: widget.background ?? theme.background,
          elevation: widget.elevation ?? theme.elevation,
          shape: widget.shape ??
              (theme.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Colors.black.withOpacity(0.15),
                    ),
                  )),
          child: Padding(
            padding: widget.padding ?? theme.padding,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.items ?? widget.itemBuilder(context),
              ),
            ),
          ),
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _setupDropdownItems();
    return Material(
      shape: widget.triggerShape,
      type: MaterialType.transparency,
      child: InkWell(
        key: _triggerKey,
        onTap: _showDropdown,
        splashColor: widget.triggerSplashColor,
        focusColor: widget.triggerFocusColor,
        hoverColor: widget.triggerHoverColor,
        highlightColor: widget.triggerHighlightColor,
        child: widget.trigger,
      ),
    );
  }

  @override
  void didChangeMetrics() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _rebuildDropdown(force: true);
    });
  }

  void _showDropdown() {
    if (!_opened && _dropdown == null) {
      setState(() {
        _opened = true;
        _dropdown = OverlayEntry(
          builder: (context) => _buildDropdown(context),
        );
        _position = Scrollable.of(context)?.position;
        _position?.addListener(_rebuildDropdown);
      });
      Overlay.of(context).insert(_dropdown);
    } else {
      _closeDropdown();
    }
  }

  void _closeDropdown() {
    _dropdown.remove();
    setState(() {
      _opened = false;
      _dropdown = null;
    });
  }

  void _rebuildDropdown({bool force = false}) {
    if (widget.scrollable || force) {
      if (_opened) {
        setState(() {
          _dropdown.remove();
          _dropdown = OverlayEntry(
            builder: (context) => _buildDropdown(context),
          );
        });

        Overlay.of(context).insert(_dropdown);
      }
    }
    if (widget.scrollToClose) {
      _position?.removeListener(_rebuildDropdown);
      _closeDropdown();
    }
  }

  RenderBox _getBox() {
    final _box = _triggerKey.currentContext.findRenderObject() as RenderBox;

    return _box;
  }

  bool _canPrint(RenderBox box) {
    final pos = box.localToGlobal(Offset.zero);
    if (pos.dy < widget.hideOnTopOffset) {
      return false;
    }

    print(pos);
    return true;
  }

  Widget _buildDropdown(BuildContext context) {
    final _box = _getBox();
    final size = _box.size;
    final _pos = _box.localToGlobal(Offset.zero);
    final can = _canPrint(_box);

    return can
        ? (widget.scrollable
            ? _buildPositioned(_pos, size)
            : GestureDetector(
                onTap: _closeDropdown,
                child: Material(
                    color: widget.backdrop,
                    child: Stack(
                      children: <Widget>[_buildPositioned(_pos, size)],
                    )),
              ))
        : Container();
  }

  Positioned _buildPositioned(Offset _offset, Size size) {
    final mq = MediaQuery.of(context).size.height;
    final offset = mq - (_offset.dy + size.height);
    print(offset);
    if (offset < widget.predictiveHeight) {
      return Positioned(
        bottom: offset + size.height,
        left: _offset.dx,
        child: _dropdownContent,
      );
    } else {
      return Positioned(
        top: _offset.dy + size.height,
        left: _offset.dx,
        child: _dropdownContent,
      );
    }
  }

  @override
  void dispose() {
    _dropdown?.remove();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
