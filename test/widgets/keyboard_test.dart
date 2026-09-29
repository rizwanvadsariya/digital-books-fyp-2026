import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fehm_e_quran/blocs/answers_cubit.dart';
import 'package:fehm_e_quran/widgets/exercise/answer_field.dart';
import 'package:fehm_e_quran/widgets/keyboard/arabic_keyboard.dart';
import 'package:fehm_e_quran/widgets/keyboard/keyboard_cubit.dart';
import 'package:fehm_e_quran/widgets/keyboard/keyboard_layouts.dart';
import 'package:fehm_e_quran/widgets/keyboard/text_editing.dart';

import '../helpers.dart';

void main() {
  group('text editing', () {
    test('a haraka is inserted directly after the letter before the caret', () {
      var v = const TextEditingValue(
        text: 'كتب',
        selection: TextSelection.collapsed(offset: 1),
      );
      v = insertText(v, 'َ'); // fatha on ك
      expect(v.text, 'كَتب');
      expect(v.selection.baseOffset, 2);
    });

    test('backspace removes only the haraka, not its letter', () {
      const v = TextEditingValue(
        text: 'كَ',
        selection: TextSelection.collapsed(offset: 2),
      );
      expect(deleteBackward(v).text, 'ك');
    });

    test('backspace deletes a selection', () {
      const v = TextEditingValue(
        text: 'abcd',
        selection: TextSelection(baseOffset: 1, extentOffset: 3),
      );
      expect(deleteBackward(v).text, 'ad');
    });

    test('insert with an invalid selection appends', () {
      final v = insertText(const TextEditingValue(text: 'ab'), 'c');
      expect(v.text, 'abc');
    });
  });

  testWidgets('tapping a blank opens the keyboard and typed text is saved', (
    tester,
  ) async {
    final store = await freshStore();
    final answers = AnswersCubit(store);
    final keyboard = KeyboardCubit();
    await tester.pumpWidget(
      harness(
        Column(
          children: [
            const AnswerField(id: '11_2_0', language: KeyboardLanguage.arabic),
            BlocKeyboardDock(keyboard: keyboard),
          ],
        ),
        store: store,
        answers: answers,
        keyboard: keyboard,
      ),
    );

    expect(find.byType(ArabicKeyboard), findsNothing);
    await tester.tap(find.byType(TextField));
    await tester.pump(const Duration(milliseconds: 400));
    expect(keyboard.state.activeId, '11_2_0');
    expect(find.byType(ArabicKeyboard), findsOneWidget);

    await tester.tap(find.text('ك'));
    await tester.tap(find.text('◌َ')); // fatha key
    await tester.tap(find.text('ت'));
    await tester.pump();
    expect(answers.answerFor('11_2_0'), 'كَت');

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    expect(answers.answerFor('11_2_0'), 'كَ');

    // Switch to Urdu and type a Urdu-only letter.
    await tester.tap(find.text('اردو').first);
    await tester.pump();
    await tester.tap(find.text('ے'));
    await tester.pump();
    expect(answers.answerFor('11_2_0'), 'كَے');

    // Done closes the keyboard; the answer is persisted.
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ArabicKeyboard), findsNothing);
    expect(store.readAnswers()['11_2_0'], 'كَے');
  });

  testWidgets('check button grades against the book key', (tester) async {
    final store = await freshStore({'answers.v1': '{"5_1_0":"كتاب"}'});
    final answers = AnswersCubit(store);
    await tester.pumpWidget(
      harness(
        const AnswerField(id: '5_1_0', answerKey: 'کِتَاب'),
        store: store,
        answers: answers,
      ),
    );
    await tester.tap(find.byIcon(Icons.task_alt));
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}

/// Minimal stand-in for the reader's docked keyboard slot.
class BlocKeyboardDock extends StatelessWidget {
  const BlocKeyboardDock({super.key, required this.keyboard});

  final KeyboardCubit keyboard;

  @override
  Widget build(BuildContext context) => StreamBuilder<KeyboardState>(
    stream: keyboard.stream,
    initialData: keyboard.state,
    builder: (_, snap) => snap.data!.customVisible
        ? const ArabicKeyboard()
        : const SizedBox.shrink(),
  );
}
