import 'package:flutter/material.dart';
import 'package:sports_bet/database.dart';
import 'package:sports_bet/tempData.dart';
import 'color_utils.dart';
import 'common_styles.dart';
import 'models/user.dart';
import 'raised_gradient_button.dart';

var _titleController = TextEditingController(text: TempData.match.title);
var _commentController = TextEditingController(text: TempData.match.comment);
var _dateController = TextEditingController(text: TempData.match.date);

class EditMatchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditMatchScreenState();
  }
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new FloatingActionButton(
              onPressed: () async {
                TempData.match.title = _titleController.text;
                TempData.match.comment = _commentController.text;
                TempData.match.date = _dateController.text;
                await DBProvider.db.updateMatch(TempData.match);
                Navigator.pop(context);
              },
              tooltip: 'Increment',
              child: Icon(
                Icons.save,
              )),
          SizedBox(
            height: 10,
          ),
          new FloatingActionButton(
              onPressed: () {
                DBProvider.db.deleteMatch(TempData.match.id);
                Navigator.pop(context);
              },
              tooltip: 'Increment',
              child: Icon(
                Icons.delete,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.40,
                width: double.infinity,
                decoration: BoxDecoration(gradient: ColorUtils.appBarGradient),
              ),
              Positioned(
                top: 150,
                left: 10,
                right: 10,
                child: EditMatchFormWidget(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EditMatchFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditMatchFormWidgetState();
  }
}

class _EditMatchFormWidgetState extends State<EditMatchFormWidget> {
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        children: <Widget>[
          Card(
            elevation: 8,
            child: Column(
              children: <Widget>[
                _buildLogo(),
                _buildTitleField(context),
                _buildCommentField(context),
                _buildDateField(context),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Image.asset(
        "images/ic_launcher.png",
        height: 100,
        width: 100,
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: TextFormField(
        controller: _titleController,
        textInputAction: TextInputAction.next,
        decoration: CommonStyles.textFormFieldStyle("Title", ""),
      ),
    );
  }

  Widget _buildCommentField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: TextFormField(
        controller: _commentController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: CommonStyles.textFormFieldStyle("Comment", ""),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: TextFormField(
        controller: _dateController,
        decoration: CommonStyles.textFormFieldStyle("Date", ""),
      ),
    );
  }
}
