library animated_custom_dropdown;

import 'dart:async';
import 'package:flutter/material.dart';

export 'custom_dropdown.dart';

part 'animated_section.dart';
part 'dropdown_field.dart';
part 'dropdown_overlay/dropdown_overlay.dart';
part 'dropdown_overlay/widgets/items_list.dart';
part 'dropdown_overlay/widgets/search_field.dart';
part 'overlay_builder.dart';

enum _SearchType { onListData, onRequestData }

enum _DropdownType {
  singleValue,
  multiSelect,
}

class _ValueNotifierList<T> extends ValueNotifier<List<T>> {
  _ValueNotifierList(super.value);

  void add(T valueToAdd) {
    value = [...value, valueToAdd];
  }

  void remove(T valueToRemove) {
    value = value.where((value) => value != valueToRemove).toList();
  }
}

const _defaultFillColor = Colors.white;
const _defaultErrorColor = Colors.red;

mixin CustomDropdownListFilter {
  /// Used to filter elements against query on
  /// [CustomDropdown<T>.search] or [CustomDropdown<T>.searchRequest]
  bool filter(String query);
}

const _defaultBorderRadius = BorderRadius.all(
  Radius.circular(12),
);

final Border _defaultErrorBorder = Border.all(
  color: _defaultErrorColor,
  width: 1.5,
);

const _defaultErrorStyle = TextStyle(
  color: _defaultErrorColor,
  fontSize: 14,
  height: 0.5,
);

const _defaultHintValue = 'Select value';

typedef _ListItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);
typedef _HeaderBuilder<T> = Widget Function(
  BuildContext context,
  T selectedItem,
);
typedef _HeaderListBuilder<T> = Widget Function(
  BuildContext context,
  List<T> selectedItems,
);
typedef _HintBuilder = Widget Function(
  BuildContext context,
  String hint,
);
typedef _NoResultFoundBuilder = Widget Function(
  BuildContext context,
  String text,
);

class CustomDropdown<T> extends StatefulWidget {
  /// The list of items the user can select.
  final List<T>? items;

  /// Initial selected item from the list of [items].
  final T? initialItem;

  /// Text that suggests what sort of data the dropdown represents.
  final String? hintText;

  /// Border for closed state of [CustomDropdown].
  final BoxBorder? closedBorder;

  /// Border radius for closed state of [CustomDropdown].
  final BorderRadius? closedBorderRadius;

  /// Border for opened/expanded state of [CustomDropdown].
  final BoxBorder? expandedBorder;

  /// Border radius for opened/expanded state of [CustomDropdown].
  final BorderRadius? expandedBorderRadius;

  /// A method that validates the selected item.
  /// Returns an error string to display as per the validation, or null otherwise.
  final String? Function(T?)? validator;

  /// Error border for closed state of [CustomDropdown].
  final BoxBorder? closedErrorBorder;

  /// Error border for opened/expanded state of [CustomDropdown].
  final BoxBorder? expandedErrorBorder;

  /// Error border radius for closed state of [CustomDropdown].
  final BorderRadius? closedErrorBorderRadius;

  /// Error border radius for opened/expanded state of [CustomDropdown].
  final BorderRadius? expandedErrorBorderRadius;

  /// The style to use for the string returning from [validator].
  final TextStyle? errorStyle;

  /// Enable the validation listener on item change.
  /// This implies to [validator] everytime when the item change.
  final bool validateOnChange;

  /// Suffix icon for closed state of [CustomDropdown].
  final Widget? closedSuffixIcon;

  /// Suffix icon for opened/expanded state of [CustomDropdown].
  final Widget? expandedSuffixIcon;

  /// Called when the item of the [CustomDropdown] should change.
  final Function(T)? onChanged;

  /// Called when the list of items of the [CustomDropdown] should change.
  final Function(List<T>)? onListChanged;

  /// Hide the selected item from the [items] list.
  final bool excludeSelected;

  /// [CustomDropdown] field color (closed state).
  final Color? closedFillColor;

  /// [CustomDropdown] overlay color (opened/expanded state).
  final Color? expandedFillColor;

  /// Can close [CustomDropdown] overlay by tapping outside.
  /// Here "outside" covers the entire screen.
  final bool canCloseOutsideBounds;

  /// Hide the selected item field when [CustomDropdown] overlay opened/expanded.
  final bool hideSelectedFieldWhenExpanded;

  /// The asynchronous computation from which the items list returns.
  final Future<List<T>> Function(String)? futureRequest;

  /// Text that notify there's no search results match.
  final String? noResultFoundText;

  /// Duration after which the [futureRequest] is to be executed.
  final Duration? futureRequestDelay;

  /// The [listItemBuilder] that will be used to build item on demand.
  // ignore: library_private_types_in_public_api
  final _ListItemBuilder<T>? listItemBuilder;

  /// The [headerBuilder] that will be used to build [CustomDropdown] header field.
  // ignore: library_private_types_in_public_api
  final _HeaderBuilder<T>? headerBuilder;

  /// The [hintBuilder] that will be used to build [CustomDropdown] hint of header field.
  // ignore: library_private_types_in_public_api
  final _HintBuilder? hintBuilder;

  /// The [noResultFoundBuilder] that will be used to build area when there's no search results match.
  // ignore: library_private_types_in_public_api
  final _NoResultFoundBuilder? noResultFoundBuilder;

  final _SearchType? _searchType;

  final _DropdownType _widgetType;

  /// Initial selected items from the list of [items].
  final List<T> initialItems;

  /// A method that validates the selected items.
  /// Returns an error string to display as per the validation, or null otherwise.
  final String? Function(List<T>)? listValidator;

  // TODO(ivn): Add muliselect constructor
  CustomDropdown({
    Key? key,
    required this.items,
    this.initialItem,
    this.hintText,
    this.noResultFoundText,
    this.errorStyle,
    this.closedErrorBorder,
    this.closedErrorBorderRadius,
    this.expandedErrorBorder,
    this.expandedErrorBorderRadius,
    this.validator,
    this.validateOnChange = true,
    this.closedBorder,
    this.closedBorderRadius,
    this.expandedBorder,
    this.expandedBorderRadius,
    this.closedSuffixIcon,
    this.expandedSuffixIcon,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
    this.onChanged,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.excludeSelected = true,
    this.closedFillColor = Colors.white,
    this.expandedFillColor = Colors.white,
  })  : assert(
          items!.isNotEmpty,
          'Items list must contain at least one item.',
        ),
        assert(
          initialItem == null || items!.contains(initialItem),
          'Initial item must match with one of the item in items list.',
        ),
        _searchType = null,
        futureRequest = null,
        futureRequestDelay = null,
        noResultFoundBuilder = null,
        _widgetType = _DropdownType.singleValue,
        initialItems = [],
        onListChanged = null,
        listValidator = null,
        super(key: key);

  CustomDropdown.search({
    Key? key,
    required this.items,
    this.initialItem,
    this.hintText,
    this.noResultFoundText,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
    this.noResultFoundBuilder,
    this.errorStyle,
    this.closedErrorBorder,
    this.closedErrorBorderRadius,
    this.expandedErrorBorder,
    this.expandedErrorBorderRadius,
    this.validator,
    this.validateOnChange = true,
    this.closedBorder,
    this.closedBorderRadius,
    this.closedSuffixIcon,
    this.expandedSuffixIcon,
    this.expandedBorder,
    this.expandedBorderRadius,
    this.onChanged,
    this.excludeSelected = true,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.closedFillColor = Colors.white,
    this.expandedFillColor = Colors.white,
  })  : assert(
          items!.isNotEmpty,
          'Items list must contain at least one item.',
        ),
        assert(
          initialItem == null || items!.contains(initialItem),
          'Initial item must match with one of the item in items list.',
        ),
        _searchType = _SearchType.onListData,
        futureRequest = null,
        futureRequestDelay = null,
        _widgetType = _DropdownType.singleValue,
        initialItems = [],
        onListChanged = null,
        listValidator = null,
        super(key: key);

  const CustomDropdown.searchRequest({
    Key? key,
    required this.futureRequest,
    this.futureRequestDelay,
    this.initialItem,
    this.items,
    this.hintText,
    this.noResultFoundText,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
    this.noResultFoundBuilder,
    this.errorStyle,
    this.closedErrorBorder,
    this.closedErrorBorderRadius,
    this.expandedErrorBorder,
    this.expandedErrorBorderRadius,
    this.validator,
    this.validateOnChange = true,
    this.closedBorder,
    this.closedBorderRadius,
    this.expandedBorder,
    this.expandedBorderRadius,
    this.closedSuffixIcon,
    this.expandedSuffixIcon,
    this.onChanged,
    this.excludeSelected = true,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.closedFillColor = Colors.white,
    this.expandedFillColor = Colors.white,
  })  : _searchType = _SearchType.onRequestData,
        _widgetType = _DropdownType.singleValue,
        initialItems = const [],
        onListChanged = null,
        listValidator = null,
        super(key: key);

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final layerLink = LayerLink();
  late ValueNotifier<T?> selectedItemNotifier;
  late _ValueNotifierList<T> selectedItemsNotifier;

  @override
  void initState() {
    super.initState();
    selectedItemNotifier = ValueNotifier(widget.initialItem);
    selectedItemsNotifier = _ValueNotifierList(widget.initialItems);
  }

  @override
  void dispose() {
    selectedItemNotifier.dispose();
    selectedItemsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeHintText = widget.hintText ?? _defaultHintValue;

    return FormField<(T?, List<T>)>(
      initialValue: (selectedItemNotifier.value, selectedItemsNotifier.value),
      validator: (val) {
        if (widget.validator != null) {
          return widget.validator!(val?.$1);
        }
        if (widget.listValidator != null && val != null) {
          return widget.listValidator!(val.$2);
        }
        return null;
      },
      builder: (formFieldState) {
        return InputDecorator(
          decoration: InputDecoration(
            errorStyle: widget.errorStyle ?? _defaultErrorStyle,
            errorText: formFieldState.errorText,
            border: InputBorder.none,
          ),
          child: _OverlayBuilder(
            overlay: (size, hideCallback) {
              return _DropdownOverlay<T>(
                onItemSelect: (T value) {
                  switch (widget._widgetType) {
                    case _DropdownType.singleValue:
                      selectedItemNotifier.value = value;
                      widget.onChanged?.call(value);
                      formFieldState.didChange((value, []));
                    case _DropdownType.multiSelect:
                      final currentVal = selectedItemsNotifier.value.toList();
                      currentVal.contains(value)
                          ? currentVal.remove(value)
                          : currentVal.add(value);
                      selectedItemsNotifier.value = currentVal;
                      widget.onListChanged?.call(currentVal);
                      formFieldState.didChange((null, currentVal));
                  }
                  if (widget.validateOnChange) {
                    formFieldState.validate();
                  }
                },
                noResultFoundText:
                    widget.noResultFoundText ?? 'No result found.',
                noResultFoundBuilder: widget.noResultFoundBuilder,
                items: widget.items ?? [],
                selectedItemNotifier: selectedItemNotifier,
                size: size,
                listItemBuilder: widget.listItemBuilder,
                layerLink: layerLink,
                hideOverlay: hideCallback,
                headerBuilder: widget.headerBuilder,
                hintText: safeHintText,
                hintBuilder: widget.hintBuilder,
                excludeSelected: widget.excludeSelected,
                canCloseOutsideBounds: widget.canCloseOutsideBounds,
                searchType: widget._searchType,
                border: formFieldState.hasError
                    ? widget.expandedErrorBorder ?? _defaultErrorBorder
                    : widget.expandedBorder,
                borderRadius: formFieldState.hasError
                    ? widget.expandedErrorBorderRadius
                    : widget.expandedBorderRadius,
                futureRequest: widget.futureRequest,
                futureRequestDelay: widget.futureRequestDelay,
                hideSelectedFieldWhenOpen: widget.hideSelectedFieldWhenExpanded,
                fillColor: widget.expandedFillColor,
                suffixIcon: widget.expandedSuffixIcon,
              );
            },
            child: (showCallback) {
              return CompositedTransformTarget(
                link: layerLink,
                child: _DropDownField<T>(
                  onTap: showCallback,
                  selectedItemNotifier: selectedItemNotifier,
                  border: formFieldState.hasError
                      ? widget.closedErrorBorder ?? _defaultErrorBorder
                      : widget.closedBorder,
                  borderRadius: formFieldState.hasError
                      ? widget.closedErrorBorderRadius
                      : widget.closedBorderRadius,
                  hintText: safeHintText,
                  hintBuilder: widget.hintBuilder,
                  headerBuilder: widget.headerBuilder,
                  suffixIcon: widget.closedSuffixIcon,
                  fillColor: widget.closedFillColor,
                  widgetType: widget._widgetType,
                  selectedItemsNotifier: selectedItemsNotifier,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
