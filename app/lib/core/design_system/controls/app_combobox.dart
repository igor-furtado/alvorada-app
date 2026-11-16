import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../app_icons.dart';
import '../app_tokens.dart';
import '../design_system_localizations.dart';
import 'app_text_input.dart';

const _menuMaxHeight = 240.0;

/// Campo de seleção pesquisável para valores pertencentes a uma lista.
///
/// Use [AppCombobox.multiple] quando mais de um valor puder ser selecionado.
class AppCombobox<T extends Object> extends StatefulWidget {
  const AppCombobox({
    required this.options,
    required this.displayStringForOption,
    this.value,
    this.onChanged,
    this.placeholder,
    this.semanticLabel,
    this.emptyMessage,
    this.showClear = false,
    this.disabled = false,
    this.autoHighlight = true,
    this.isOptionEnabled,
    this.errorText,
    super.key,
  }) : multiple = false,
       values = null,
       onValuesChanged = null;

  const AppCombobox.multiple({
    required this.options,
    required this.displayStringForOption,
    this.values = const [],
    this.onValuesChanged,
    this.placeholder,
    this.semanticLabel,
    this.emptyMessage,
    this.showClear = false,
    this.disabled = false,
    this.autoHighlight = true,
    this.isOptionEnabled,
    this.errorText,
    super.key,
  }) : multiple = true,
       value = null,
       onChanged = null;

  final List<T> options;
  final String Function(T option) displayStringForOption;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<T>? values;
  final ValueChanged<List<T>>? onValuesChanged;
  final String? placeholder;
  final String? semanticLabel;
  final String? emptyMessage;
  final bool showClear;
  final bool disabled;
  final bool autoHighlight;
  final bool Function(T option)? isOptionEnabled;
  final String? errorText;
  final bool multiple;

  @override
  State<AppCombobox<T>> createState() => _AppComboboxState<T>();
}

class _AppComboboxState<T extends Object> extends State<AppCombobox<T>> {
  final _overlayController = OverlayPortalController();
  final _fieldKey = GlobalKey();
  final _textController = TextEditingController();
  final _inputFocusNode = FocusNode();
  final _keyboardFocusNode = FocusNode(skipTraversal: true);
  final _scrollController = ScrollController(keepScrollOffset: false);
  final _tapRegionGroup = Object();

  var _open = false;
  var _editing = false;
  var _highlightedIndex = -1;
  var _query = '';

  bool get _enabled =>
      !widget.disabled && (widget.multiple ? widget.onValuesChanged != null : widget.onChanged != null);

  List<T> get _selectedValues => widget.values ?? const [];

  List<T> get _filteredOptions {
    final query = _normalize(_query.trim());
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((option) => _normalize(widget.displayStringForOption(option)).contains(query))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(_handleInputFocusChange);
    _syncSingleValue();
  }

  @override
  void didUpdateWidget(covariant AppCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.multiple && !_editing) _syncSingleValue();
    if (!_enabled && _open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setOpen(false);
      });
    }
  }

  @override
  void dispose() {
    _inputFocusNode
      ..removeListener(_handleInputFocusChange)
      ..dispose();
    _keyboardFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncSingleValue() {
    final value = widget.value;
    final text = value == null ? '' : widget.displayStringForOption(value);
    if (_textController.text == text) return;
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _handleInputFocusChange() {
    if (_inputFocusNode.hasFocus) {
      _editing = true;
      _query = '';
      if (!widget.multiple && _textController.text.isNotEmpty) {
        _textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _textController.text.length,
        );
      }
      _setOpen(true);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _inputFocusNode.hasFocus) return;
      _editing = false;
      if (!widget.multiple) _syncSingleValue();
      if (!_open) setState(() {});
    });
  }

  void _setOpen(bool value) {
    if (_open == value || (value && !_enabled)) return;
    setState(() {
      _open = value;
      _resetHighlight();
    });
    if (value) {
      _overlayController.show();
    } else {
      _overlayController.hide();
      if (!widget.multiple) {
        _editing = false;
        _query = '';
        _syncSingleValue();
      } else {
        _query = '';
        _textController.clear();
      }
    }
  }

  void _handleQueryChanged(String value) {
    _query = value;
    if (!_open) _setOpen(true);
    setState(_resetHighlight);
  }

  void _resetHighlight() {
    final options = _filteredOptions;
    _highlightedIndex = widget.autoHighlight ? options.indexWhere(_isEnabled) : -1;
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  bool _isEnabled(T option) => widget.isOptionEnabled?.call(option) ?? true;

  bool _isSelected(T option) => widget.multiple ? _selectedValues.contains(option) : widget.value == option;

  void _select(T option) {
    if (!_isEnabled(option)) return;
    if (widget.multiple) {
      final next = [..._selectedValues];
      if (next.contains(option)) {
        next.remove(option);
      } else {
        next.add(option);
      }
      widget.onValuesChanged?.call(List.unmodifiable(next));
      _query = '';
      _textController.clear();
      setState(_resetHighlight);
      _inputFocusNode.requestFocus();
      return;
    }
    widget.onChanged?.call(option);
    _query = '';
    _textController.text = widget.displayStringForOption(option);
    _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    _setOpen(false);
    _inputFocusNode.unfocus();
  }

  void _clear() {
    if (widget.multiple) {
      widget.onValuesChanged?.call(List<T>.unmodifiable(const []));
      _query = '';
      _textController.clear();
    } else {
      widget.onChanged?.call(null);
      _query = '';
      _textController.clear();
    }
    if (_open) setState(_resetHighlight);
    _inputFocusNode.requestFocus();
  }

  void _removeLastChip() {
    if (!widget.multiple || _textController.text.isNotEmpty || _selectedValues.isEmpty) return;
    final next = [..._selectedValues]..removeLast();
    widget.onValuesChanged?.call(List.unmodifiable(next));
  }

  KeyEventResult _handleKeyEvent(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape && _open) {
      _setOpen(false);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _removeLastChip();
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (!_open) {
        _setOpen(true);
      } else {
        _moveHighlight(1);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && _open) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter && _open) {
      final options = _filteredOptions;
      if (_highlightedIndex >= 0 && _highlightedIndex < options.length) {
        _select(options[_highlightedIndex]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _moveHighlight(int direction) {
    final options = _filteredOptions;
    if (options.isEmpty) return;
    var index = _highlightedIndex;
    for (var attempts = 0; attempts < options.length; attempts++) {
      index = (index + direction) % options.length;
      if (index < 0) index = options.length - 1;
      if (_isEnabled(options[index])) {
        setState(() => _highlightedIndex = index);
        _scrollHighlightedIntoView(index);
        return;
      }
    }
  }

  void _scrollHighlightedIntoView(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final itemHeight = context.tokens.layout.inputHeight;
      final target = index * itemHeight;
      final viewport = _scrollController.position.viewportDimension;
      final current = _scrollController.offset;
      if (target < current) {
        _scrollController.jumpTo(target.clamp(0.0, _scrollController.position.maxScrollExtent));
      } else if (target + itemHeight > current + viewport) {
        final offset = target + itemHeight - viewport;
        _scrollController.jumpTo(offset.clamp(0.0, _scrollController.position.maxScrollExtent));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasValue = widget.multiple ? _selectedValues.isNotEmpty : widget.value != null;
    return TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: (_) => _setOpen(false),
      child: OverlayPortal.overlayChildLayoutBuilder(
        controller: _overlayController,
        overlayChildBuilder: (_, layoutInfo) => _buildPopup(layoutInfo),
        child: Focus(
          focusNode: _keyboardFocusNode,
          onKeyEvent: _handleKeyEvent,
          child: Semantics(
            label: widget.semanticLabel,
            enabled: _enabled,
            expanded: _open,
            child: Opacity(
              opacity: _enabled ? 1 : tokens.opacity.disabled,
              child: widget.multiple ? _buildMultipleField(hasValue) : _buildSingleField(hasValue),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleField(bool hasValue) => AppTextInput(
    key: _fieldKey,
    controller: _textController,
    focusNode: _inputFocusNode,
    enabled: _enabled,
    placeholder: widget.placeholder,
    semanticLabel: widget.semanticLabel,
    errorText: widget.errorText,
    onChanged: _handleQueryChanged,
    onSubmitted: (_) {
      final options = _filteredOptions;
      if (_highlightedIndex >= 0 && _highlightedIndex < options.length) {
        _select(options[_highlightedIndex]);
      }
    },
    suffixIcon: _ComboboxActions(
      open: _open,
      enabled: _enabled,
      showClear: widget.showClear && hasValue,
      onClear: _clear,
      onToggle: () {
        if (_open) {
          _setOpen(false);
        } else {
          _inputFocusNode.requestFocus();
          _setOpen(true);
        }
      },
    ),
  );

  Widget _buildMultipleField(bool hasValue) {
    final tokens = context.tokens;
    final borderColor = widget.errorText != null
        ? tokens.colors.error
        : _inputFocusNode.hasFocus || _open
        ? tokens.colors.focusRing
        : tokens.colors.controlOutline;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          key: _fieldKey,
          duration: tokens.motion.fast,
          constraints: BoxConstraints(minHeight: tokens.layout.inputHeight),
          padding: EdgeInsets.only(left: tokens.spacing.sm),
          decoration: BoxDecoration(
            color: tokens.colors.surface,
            borderRadius: tokens.borders.lg,
            border: Border.all(
              color: borderColor,
              width: _inputFocusNode.hasFocus || _open ? tokens.borders.widthStrong : tokens.borders.widthHairline,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: tokens.spacing.xs,
                  runSpacing: tokens.spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final option in _selectedValues)
                      _ComboboxChip(
                        label: widget.displayStringForOption(option),
                        enabled: _enabled,
                        onRemove: () {
                          final next = [..._selectedValues]..remove(option);
                          widget.onValuesChanged?.call(List.unmodifiable(next));
                          _inputFocusNode.requestFocus();
                        },
                      ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 72, maxWidth: 220),
                      child: TextField(
                        controller: _textController,
                        focusNode: _inputFocusNode,
                        enabled: _enabled,
                        onChanged: _handleQueryChanged,
                        decoration: InputDecoration(
                          hintText: _selectedValues.isEmpty ? widget.placeholder : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          constraints: BoxConstraints(minHeight: tokens.layout.inputHeight),
                          contentPadding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
                        ),
                        style: tokens.typography.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
              _ComboboxActions(
                open: _open,
                enabled: _enabled,
                showClear: widget.showClear && hasValue,
                onClear: _clear,
                onToggle: () {
                  _inputFocusNode.requestFocus();
                  _setOpen(!_open);
                },
              ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(left: tokens.spacing.md, top: tokens.spacing.xs),
            child: Text(
              widget.errorText!,
              style: tokens.typography.errorText,
            ),
          ),
      ],
    );
  }

  Widget _buildPopup(OverlayChildLayoutInfo layoutInfo) {
    final tokens = context.tokens;
    final options = _filteredOptions;
    final fieldRect = MatrixUtils.transformRect(
      layoutInfo.childPaintTransform,
      Offset.zero & layoutInfo.childSize,
    );
    final estimatedHeight = options.isEmpty
        ? tokens.layout.inputHeight + (tokens.spacing.xs * 2)
        : (options.length * tokens.layout.inputHeight) + (tokens.spacing.xs * 2);
    final desiredHeight = estimatedHeight.clamp(0.0, _menuMaxHeight);
    final spaceBelow = layoutInfo.overlaySize.height - fieldRect.bottom;
    final spaceAbove = fieldRect.top;
    final opensUpwards = spaceBelow < desiredHeight + tokens.spacing.xs && spaceAbove > spaceBelow;
    final availableHeight = (opensUpwards ? spaceAbove : spaceBelow) - tokens.spacing.xs;
    final maxHeight = availableHeight.clamp(0.0, _menuMaxHeight);
    return Positioned(
      left: fieldRect.left,
      width: fieldRect.width,
      top: opensUpwards ? null : fieldRect.bottom + tokens.spacing.xs,
      bottom: opensUpwards ? layoutInfo.overlaySize.height - fieldRect.top + tokens.spacing.xs : null,
      child: TapRegion(
        groupId: _tapRegionGroup,
        child: Material(
          color: tokens.colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: EdgeInsets.all(tokens.spacing.xs),
            decoration: BoxDecoration(
              color: tokens.colors.popover,
              border: Border.all(color: tokens.colors.border),
              borderRadius: tokens.borders.lg,
              boxShadow: tokens.overlayShadow,
            ),
            child: options.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(tokens.spacing.md),
                    child: Text(
                      widget.emptyMessage ?? context.l10n.comboboxEmpty,
                      textAlign: TextAlign.center,
                      style: tokens.typography.supportingText,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemExtent: tokens.layout.inputHeight,
                    itemBuilder: (_, index) {
                      final option = options[index];
                      return _ComboboxOption(
                        label: widget.displayStringForOption(option),
                        selected: _isSelected(option),
                        highlighted: index == _highlightedIndex,
                        enabled: _isEnabled(option),
                        onPressed: () => _select(option),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _ComboboxActions extends StatelessWidget {
  const _ComboboxActions({
    required this.open,
    required this.enabled,
    required this.showClear,
    required this.onClear,
    required this.onToggle,
  });

  final bool open;
  final bool enabled;
  final bool showClear;
  final VoidCallback onClear;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showClear)
          IconButton(
            tooltip: context.l10n.clearSelection,
            onPressed: enabled ? onClear : null,
            icon: Icon(AppIcons.close, size: tokens.icons.sm),
          ),
        IconButton(
          tooltip: open ? context.l10n.closeOptions : context.l10n.openOptions,
          onPressed: enabled ? onToggle : null,
          icon: Icon(
            AppIcons.expandMore,
            size: tokens.icons.sm,
          ),
        ),
      ],
    );
  }
}

class _ComboboxChip extends StatelessWidget {
  const _ComboboxChip({
    required this.label,
    required this.enabled,
    required this.onRemove,
  });

  final String label;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      constraints: BoxConstraints(minHeight: tokens.spacing.xxl),
      padding: EdgeInsets.only(left: tokens.spacing.sm),
      decoration: BoxDecoration(
        color: tokens.colors.surfaceSubtle,
        borderRadius: tokens.borders.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: tokens.typography.labelMedium),
          IconButton(
            tooltip: context.l10n.removeItem(label),
            onPressed: enabled ? onRemove : null,
            visualDensity: VisualDensity.compact,
            constraints: BoxConstraints.tightFor(
              width: tokens.spacing.xxl,
              height: tokens.spacing.xxl,
            ),
            padding: EdgeInsets.zero,
            icon: Icon(AppIcons.close, size: tokens.icons.sm),
          ),
        ],
      ),
    );
  }
}

class _ComboboxOption extends StatelessWidget {
  const _ComboboxOption({
    required this.label,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool highlighted;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : tokens.opacity.disabled,
        child: Material(
          color: highlighted ? tokens.colors.surfaceSubtle : tokens.colors.transparent,
          borderRadius: tokens.borders.sm,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: tokens.borders.sm,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.typography.bodySmall,
                    ),
                  ),
                  if (selected) Icon(AppIcons.check, size: tokens.icons.sm, color: tokens.colors.onSurface),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _normalize(String value) {
  const accented = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const plain = 'aaaaaeeeeiiiiooooouuuuc';
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    final index = accented.indexOf(character);
    buffer.write(index < 0 ? character : plain[index]);
  }
  return buffer.toString();
}
