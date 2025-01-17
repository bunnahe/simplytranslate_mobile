// Thanks to ChatGPT for helping me convert the python code to Dart:
// https://codeberg.org/SimpleWeb/SimplyTranslate-Engines/src/branch/master/simplytranslate_engines/googletranslate.py

library simplytranslate;

import 'dart:convert';
import 'dart:typed_data';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:simplytranslate_mobile/data.dart';

const userAgent =
    "Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0";

Future<Uint8List> tts(String text, String language) async {
  final url = Uri.parse(
    "https://translate.google.com/translate_tts?tl=$language&q=${Uri.encodeQueryComponent(text)}&client=tw-ob",
  );
  final response = await http.get(url, headers: {"User-Agent": userAgent});
  return response.bodyBytes;
}

Future<Map<String, dynamic>> translate(
  String text,
  String from,
  String to,
) async {
  Map<String, dynamic> response = {};

  var document = html.parse((await http.get(Uri.parse(
    "https://translate.google.com/m?tl=$to&hl=$from&q=${Uri.encodeQueryComponent(text)}",
  )))
      .body);
  response['text'] =
      document.getElementsByClassName('result-container')[0].innerHtml;

  try {
    var url = Uri.parse(
      "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=MkEWBc&rt=c",
    );

    var req = jsonEncode([
      [text, from, to, true],
      [null]
    ]);

    req = jsonEncode([
      [
        ["MkEWBc", req, null, "generic"]
      ]
    ]);

    req = "f.req=" + Uri.encodeComponent(req);

    var resp = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=utf-8",
        "User-Agent": userAgent,
      },
      body: req,
    );

    var responseText = resp.body;

    var numMatch = RegExp(r"\n(\d+)\n").firstMatch(responseText);
    var frontPad = numMatch!.end;
    var endNum = frontPad + int.parse(numMatch.group(1)!) - 1;
    var data = jsonDecode(responseText.substring(frontPad, endNum));
    data = data[0][2];
    data = jsonDecode(data);

    try {
      response["definitions"] = {};
      for (var x = 0; x < data[3][1][0].length; x++) {
        String definitionType = data[3][1][0][x][0] ?? "unknown";

        response["definitions"][definitionType] = [];
        for (var i = 0; i < data[3][1][0][x][1].length; i++) {
          response["definitions"][definitionType].add({});
          var definitionBox = data[3][1][0][x][1][i];

          try {
            response["definitions"][definitionType][i]["dictionary"] =
                definitionBox[4][0][0];
          } catch (e) {}

          try {
            response["definitions"][definitionType][i]["definition"] =
                definitionBox[0];
          } catch (e) {}

          try {
            var useInSentence = definitionBox[1];
            if (useInSentence != null) {
              response["definitions"][definitionType][i]["use-in-sentence"] =
                  useInSentence;
            }
          } catch (e) {}

          try {
            var synonyms = definitionBox[5];
            response["definitions"][definitionType][i]["synonyms"] = {};
            for (var synonymBox in synonyms) {
              var synonymType = "";
              try {
                synonymType = synonymBox[1][0][0];
              } catch (e) {}
              response["definitions"][definitionType][i]["synonyms"]
                  [synonymType] = [];

              try {
                var synonymList = synonymBox[0];
                for (var synonymTypeWord in synonymList) {
                  try {
                    response["definitions"][definitionType][i]["synonyms"]
                            [synonymType]
                        .add(synonymTypeWord[0]);
                  } catch (e) {}
                }
              } catch (e) {}
            }
          } catch (e) {}
        }
      }
    } catch (e) {}

    try {
      var translationBox = data[3][5][0];
      response["translations"] = {};
      for (var x = 0; x < translationBox.length; x++) {
        try {
          var translationType = translationBox[x][0] ?? "unknown";
          response["translations"][translationType] = {};
          var translationNamesBox = translationBox[x][1];
          for (var i = 0; i < translationNamesBox.length; i++) {
            response["translations"][translationType]
                [translationNamesBox[i][0]] = {};
            var frequency = translationNamesBox[i][3].toString();
            if (frequency == "3") {
              frequency = "1";
            } else if (frequency == "1") {
              frequency = "3";
            }

            response["translations"][translationType][translationNamesBox[i][0]]
                ["words"] = [];
            for (var z = 0; z < translationNamesBox[i][2].length; z++) {
              response["translations"][translationType]
                      [translationNamesBox[i][0]]["words"]
                  .add(translationNamesBox[i][2][z]);
            }

            response["translations"][translationType][translationNamesBox[i][0]]
                ["frequency"] = frequency + "/3";
          }
        } catch (e) {}
      }
    } catch (e) {}
    try {
      final detectedLanguage = data[0][2];
      if (toSelLangMap.keys.contains(detectedLanguage)) {
        fromLangVal = detectedLanguage;
        session.write('from_lang', fromLangVal);
        changeFromTxt(fromSelLangMap[fromLangVal]!);
      }
    } catch (e) {}
  } catch (e) {}

  return response;
}
