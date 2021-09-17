import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/main_localizations.dart';
import 'package:simplytranslate/widgets/copy_to_clipboard_button.dart';
import 'package:simplytranslate/widgets/delete_translation_input_button.dart';
import '../data.dart';
import './paste_clipboard_button.dart';

class TranslationInput extends StatefulWidget {
  final setStateParent;
  final translateParent;
  const TranslationInput({
    @required this.setStateParent,
    @required this.translateParent,
    Key? key,
  }) : super(key: key);

  @override
  _TranslationInputState createState() => _TranslationInputState();
}

class _TranslationInputState extends State<TranslationInput> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: boxDecorationCustom,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    minLines: 7,
                    maxLines: 10,
                    controller: translationInputController,
                    keyboardType: TextInputType.text,
                    onChanged: (String input) async {
                      setState(() {
                        translationInput = input;
                      });
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: lightgreyColor),
                        hintText:
                            AppLocalizations.of(context)!.enter_text_here),
                    style: const TextStyle(fontSize: 20),
                    onEditingComplete: () async {
                      FocusScope.of(context).unfocus();
                      widget.setStateParent(() => loading = true);
                      await widget.translateParent(translationInput);
                      widget.setStateParent(() => loading = false);
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DeleteTranslationInputButton(
                    setStateParent: setState,
                    setStateParentParent: widget.setStateParent),
                CopyToClipboardButton(translationInput),
                PasteClipboardButton(setStateParent: setState),
              ],
            ),
          )
        ],
      ),
    );
  }
}