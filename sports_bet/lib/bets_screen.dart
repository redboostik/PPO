import 'package:flutter/material.dart';
import 'package:sports_bet/yours_bets_form.dart';
import 'bets_form.dart';
import 'color_utils.dart';

class BetsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BetsScreenState();
  }
}

class _BetsScreenState extends State<BetsScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                decoration: BoxDecoration(gradient: ColorUtils.appBarGradient),
              ),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: new Stack(
                  children: <Widget>[
                    new Offstage(
                      offstage: index != 0,
                      child: new TickerMode(
                        enabled: index == 0,
                        child: new BetsFormWidget(),
                      ),
                    ),
                    new Offstage(
                      offstage: index != 1,
                      child: new TickerMode(
                        enabled: index == 1,
                        child: new YoursBetsFormWidget(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: index,
        onTap: (int index) {
          setState(() {
            this.index = index;
          });
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            title: Text("matches"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: Text("Yours matches"),
          ),
        ],
      ),
    );
  }
}
