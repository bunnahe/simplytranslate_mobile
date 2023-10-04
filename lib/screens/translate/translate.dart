
import 'package:flutter/material.dart';
import 'package:simplytranslate_mobile/screens/translate/widgets/ads/homebanner.dart';
import 'package:simplytranslate_mobile/screens/translate/widgets/output/definitions.dart';
import 'package:simplytranslate_mobile/screens/translate/widgets/output/translations.dart';
import '/data.dart';
import 'widgets/input/input.dart';
import 'widgets/output/output.dart';
import 'widgets/lang_selector/from_lang.dart';
import 'widgets/lang_selector/to_lang.dart';
import 'widgets/lang_selector/switch_lang.dart';

var _scrollController = ScrollController();

class GoogleTranslate extends StatefulWidget {
  const GoogleTranslate({Key? key}) : super(key: key);

  @override
  State<GoogleTranslate> createState() => _GoogleTranslateState();
}

var _isBefore = false;

class _GoogleTranslateState extends State<GoogleTranslate> {


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery
        .of(context)
        .orientation == Orientation.landscape)
      _isBefore = true;
    else if (MediaQuery
        .of(context)
        .orientation == Orientation.portrait &&
        _isBefore) {
      _scrollController.jumpTo(0);
      _isBefore = false;
    }
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 10);
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GoogleFromLang(),
                      GoogleSwitchLang(),
                      GoogleToLang(),
                    ],
                  ),
                  space,
                  GoogleTranslationInput(),
                  space,
                  GoogleTranslationOutput(),
                  space,
                  if (loading)
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width - 20,
                      child: LinearProgressIndicator(),
                    ),
                  Definitions(googleOutput),
                  Translations(googleOutput),
                  SizedBox(height: 50,),
                  HomeBanner()
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

}
