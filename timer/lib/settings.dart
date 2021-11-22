import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timer/models/setting_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'database.dart';
import 'main.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              child: Text(
                  MyApp.locale.value.toLanguageTag() == 'ru' ? 'ru' : 'en'),
              onPressed: () {
                DBProvider.db.updateSetting(SettingModel(
                    id: 5,
                    title: "lang",
                    value: MyApp.locale.value.toLanguageTag() == 'ru' ? 1 : 0));
                if (MyApp.locale.value.toLanguageTag() == 'ru') {
                  MyApp.locale.value = Locale('en');
                } else {
                  MyApp.locale.value = Locale('ru');
                }
              })
        ],
      ),
      body: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.font + ' 1'),
                initialValue: MyApp.font1.value.toString(),
                onChanged: (text) {
                  setState(() {
                    MyApp.font1.value = double.tryParse(text) as double;
                    DBProvider.db.updateSetting(SettingModel(
                        id: 2,
                        title: 'font1',
                        value: MyApp.font1.value.toInt()));
                  });
                },
              )),
          Container(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.font + ' 2'),
                initialValue: MyApp.font2.value.toString(),
                onChanged: (text) {
                  setState(() {
                    MyApp.font1.value = double.tryParse(text) as double;
                    DBProvider.db.updateSetting(SettingModel(
                        id: 3,
                        title: 'font2',
                        value: MyApp.font2.value.toInt()));
                  });
                },
              )),
          Container(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.font + ' 3'),
                initialValue: MyApp.font3.value.toString(),
                onChanged: (text) {
                  setState(() {
                    MyApp.font1.value = double.tryParse(text) as double;
                    DBProvider.db.updateSetting(SettingModel(
                        id: 4,
                        title: 'font3',
                        value: MyApp.font3.value.toInt()));
                  });
                },
              )),
          Container(
              padding: const EdgeInsets.all(20.0),
              child: TextButton(
                child: Text(AppLocalizations.of(context)!.deleteInfo),
                onPressed: () {
                  DBProvider.db.flush();
                },
              )),
        ],
      ),
    );
  }
}
