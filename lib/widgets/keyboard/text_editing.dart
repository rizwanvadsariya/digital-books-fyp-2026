import 'package:flutter/services.dart';

/// Inserts [text] at the caret (replacing any selection).
///
/// Harakat are Unicode combining marks, so inserting one right after a
/// letter is all that's needed for it to render on that letter.
TextEditingValue insertText(TextEditingValue value, String text) {
  final sel = _validSelection(value);
  final newText = value.text.replaceRange(sel.start, sel.end, text);
  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: sel.start + text.length),
  );
}

/// Deletes the selection, or the single code point before the caret.
///
/// Deleting one code point (rather than a whole grapheme cluster) means a
/// mistyped haraka can be removed without also deleting its base letter.
TextEditingValue deleteBackward(TextEditingValue value) {
  final sel = _validSelection(value);
  if (!sel.isCollapsed) {
    return TextEditingValue(
      text: value.text.replaceRange(sel.start, sel.end, ''),
      selection: TextSelection.collapsed(offset: sel.start),
    );
  }
  if (sel.start == 0) return value;
  var start = sel.start - 1;
  final unit = value.text.codeUnitAt(start);
  if (start > 0 && unit >= 0xDC00 && unit <= 0xDFFF) {
    final prev = value.text.codeUnitAt(start - 1);
    if (prev >= 0xD800 && prev <= 0xDBFF) start--;
  }
  return TextEditingValue(
    text: value.text.replaceRange(start, sel.start, ''),
    selection: TextSelection.collapsed(offset: start),
  );
}

TextSelection _validSelection(TextEditingValue value) {
  final sel = value.selection;
  if (!sel.isValid) return TextSelection.collapsed(offset: value.text.length);
  final len = value.text.length;
  return TextSelection(
    baseOffset: sel.start.clamp(0, len),
    extentOffset: sel.end.clamp(0, len),
  );
}
