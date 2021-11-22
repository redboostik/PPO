import 'dart:math';
import "package:flutter/material.dart";

void main() {
  runApp(Calculator());
}

class Calculator extends StatelessWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calculator',
        home: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return SimpleCalculator();
          } else {
            return ScientificCalculator();
          }
        }));
  }
}

class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({Key? key}) : super(key: key);

  @override
  _ScientificCalculatorState createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  List pref = [
    'sin',
    'cos',
    'tan',
    'ctg',
    'abs',
    'ln',
    'sqrt',
    'sqr',
    'lg',
    'log'
  ];
  List bin = ['^', '^', '*', '/', '+', '-'];
  String topText = "";
  String botText = "";
  String lastChar = 'n';
  String degRad = 'RAD';
  double trigConst = 1;
  bool isPresent = false;
  bool isMinor = false;
  double result = 0.0;
  double beforeResult = 0.0;
  int bracketsCount = 0;

  double calcLog(double x, double y) {
    return log(x) / log(y);
  }

  String fact(String x) {
    var newX = double.parse(x).ceil();
    var res = 1.0;
    for (var i = 1; i <= newX; i++) {
      res *= i;
    }
    return res.toString();
  }

  double calculating(List<String> chars) {
    List out = [];
    List stack = [];
    for (var index = 0; index < chars.length; index++) {
      if (chars[index] == 'pi') {
        out.add(pi.toString());
      } else if (chars[index] == 'e') {
        out.add(e.toString());
      } else if (chars[index].runes.last - '0'.runes.last < 10 &&
          chars[index].runes.last - '0'.runes.last >= 0) {
        out.add(chars[index]);
      } else if (chars[index] == ')') {
        if (stack.length > 0)
          while (stack.length > 0 && stack.last != '(') {
            out.add(stack.removeLast());
          }
        stack.removeLast();
      } else if (pref.contains(chars[index]) || chars[index] == '(')
        stack.add(chars[index]);
      else {
        if (stack.length > 0)
          while (stack.length > 0 &&
              stack.last != '(' &&
              (pref.contains(stack.last) ||
                  bin.indexOf(chars[index]) / 2 >=
                      bin.indexOf(stack.last) / 2)) {
            out.add(stack.removeLast());
          }
        stack.add(chars[index]);
      }
    }
    out.addAll(stack.reversed);
    stack.clear();
    for (var i = 0; i < out.length; i++) {
      if (out[i].runes.last - '0'.runes.last < 10 &&
          out[i].runes.last - '0'.runes.last >= 0) {
        stack.add(double.parse(out[i]));
      } else if (pref.contains(out[i])) {
        var ss = out[i];
        switch (out[i]) {
          case "sin":
            stack[stack.length - 1] = sin(trigConst * stack.last);
            break;
          case "cos":
            stack[stack.length - 1] = cos(trigConst * stack.last);
            break;
          case "tan":
            stack[stack.length - 1] = tan(trigConst * stack.last);
            break;
          case "ctg":
            stack[stack.length - 1] =
                cos(trigConst * stack.last) / sin(trigConst * stack.last);
            break;
          case "abs":
            stack[stack.length - 1] =
                (trigConst * double.parse(stack.last)).abs();
            break;
          case "ln":
            stack[stack.length - 1] = log(stack.last);
            break;
          case "lg":
            stack[stack.length - 1] = calcLog(stack.last, 10);
            break;
          case "log":
            stack[stack.length - 1] = calcLog(stack.last, 2);
            break;
          case "sqr":
            stack[stack.length - 1] = stack.last * stack.last;
            break;
          case "sqrt":
            stack[stack.length - 1] = pow(stack.last, 1.0 / 2);
            break;
        }
      } else {
        switch (out[i]) {
          case "^":
            var se = stack.removeLast();
            stack[stack.length - 1] = pow(stack.last, se);
            break;
          case "*":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last * se;
            break;
          case "/":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last / se;
            break;
          case "+":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last + se;
            break;
          case "-":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last - se;
            break;
        }
      }
    }
    return stack.last;
  }

  void precalculating() {
    var tempString = topText;
    tempString += ')' * bracketsCount;
    while (tempString.contains("()")) {
      tempString = tempString.replaceAll('()', '');
    }
    tempString = tempString
        .replaceAll('(', ' ( ')
        .replaceAll(')', ' ) ')
        .replaceAll('-', ' - ')
        .replaceAll('+', ' + ')
        .replaceAll('*', ' * ')
        .replaceAll('/', ' / ')
        .replaceAll('^', ' ^ ')
        .replaceAll('!', ' ! ');
    var splitString = tempString.split(" ");
    splitString.removeWhere((element) => element.length == 0);
    for (var i = 0; i < splitString.length; i++)
      if (splitString[i] == '!') {
        splitString[i - 1] = fact(splitString[i - 1]);
      }
    splitString.removeWhere((element) => element == '!');
    result = calculating(splitString);
    botText = result.toString();
    setState(() {});
    return;
  }

  void processing(String textButton) {
    switch (textButton) {
      case "RAD":
        trigConst = 1;
        degRad = 'DEG';
        break;
      case "DEG":
        trigConst = pi / 180;
        degRad = 'RAD';
        break;
      case "π":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          topText += 'pi';
        }
        break;
      case "e":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          topText += 'e';
        }
        break;
      case "n!":
        if (topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == 'i' ||
            topText.characters.last == 'e') {
          isMinor = false;
          topText += '!';
        }
        break;

      case "sin":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += 'sin(';
        }
        break;
      case "cos":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += 'cos(';
        }
        break;
      case "tan":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += 'tan(';
        }
        break;
      case "ctg":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += 'ctg(';
        }
        break;

      case '|x|':
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += 'abs(';
        }
        break;
      case "xⁿ":
        if (topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == 'i' ||
            topText.characters.last == '!' ||
            topText.characters.last == ')' ||
            topText.characters.last == 'e') {
          isMinor = false;
          bracketsCount++;
          topText += "^(";
        }
        break;
      case "eⁿ":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += "e^(";
        }
        break;
      case "ln":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += 'ln(';
        }
        break;

      case "√":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          topText += 'sqrt(';
          bracketsCount++;
        }
        break;
      case "x²":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += "sqr(";
        }
        break;
      case "lg":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText = 'lg(';
        }
        break;
      case "log":
        if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += 'log(';
        }
        break;
      case ".":
        if (!isMinor &&
            topText.runes.last - '0'.runes.last < 10 &&
            topText.runes.last - '0'.runes.last >= 0) {
          isMinor = true;
          topText += '.';
        }
        break;

      case '⌫':
        if (topText.endsWith(')')) bracketsCount++;
        if (topText.endsWith('(')) bracketsCount--;
        if (topText.endsWith('.')) isMinor = false;
        if (topText.endsWith('sqrt('))
          topText = topText.substring(0, topText.length - 5);
        else if (topText.endsWith('sin(') ||
            topText.endsWith('cos(') ||
            topText.endsWith('tan(') ||
            topText.endsWith('ctg(') ||
            topText.endsWith('abs(') ||
            topText.endsWith('sqr(') ||
            topText.endsWith('log('))
          topText = topText.substring(0, topText.length - 4);
        else if (topText.endsWith('e^(') ||
            topText.endsWith('ln(') ||
            topText.endsWith('lg('))
          topText = topText.substring(0, topText.length - 3);
        else if (topText.endsWith('pi') || topText.endsWith('^('))
          topText = topText.substring(0, topText.length - 2);
        else
          topText = topText.substring(0, topText.length - 1);
        break;
      case "÷":
        if (topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == 'i' ||
            topText.characters.last == '!' ||
            topText.characters.last == ')' ||
            topText.characters.last == 'e') {
          isMinor = false;
          topText += '/';
        }
        break;
      case "-":
        if (topText.length == 0 ||
            topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == 'i' ||
            topText.characters.last == '!' ||
            topText.characters.last == ')' ||
            topText.characters.last == 'e') {
          isMinor = false;
          topText += '-';
        }
        break;
      case "()":
        if (topText.length > 0 &&
            (topText.runes.last - '0'.runes.last < 10 &&
                    topText.runes.last - '0'.runes.last >= 0 ||
                topText.characters.last == 'i' ||
                topText.characters.last == '!' ||
                topText.characters.last == ')' ||
                topText.characters.last == 'e') &&
            bracketsCount > 0) {
          isMinor = false;
          bracketsCount--;
          topText += ')';
        } else if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e')) {
          isMinor = false;
          bracketsCount++;
          topText += '(';
        }
        break;

      case "AC":
        beforeResult = 0;
        result = 0;

        isMinor = false;
        topText = "";
        botText = "";
        result = 0;
        bracketsCount = 0;
        break;

      case "×":
        if (topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == 'i' ||
            topText.characters.last == '!' ||
            topText.characters.last == ')' ||
            topText.characters.last == 'e') {
          isMinor = false;
          topText += '*';
        }
        break;

      case "+":
        if ((topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0) ||
            topText.characters.last == 'i' ||
            topText.characters.last == '!' ||
            topText.characters.last == ')' ||
            topText.characters.last == 'e') {
          isMinor = false;
          topText += '+';
        }
        break;
      case "=":
        isMinor = false;
        topText = result.toString();
        break;
      default:
        if (topText.length == 0 ||
            topText.characters.last != 'i' &&
                topText.characters.last != '!' &&
                topText.characters.last != ')' &&
                topText.characters.last != 'e') topText += textButton;
    }
    setState(() {});
    precalculating();
    return;
  }

  Widget calcButton(String text, Color buttonColor, Color textColor) {
    return Container(
        child: FloatingActionButton(
      shape: CircleBorder(),
      backgroundColor: buttonColor,
      onPressed: () {
        processing(text);
      },
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 20),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerRight,
              height: MediaQuery.of(context).size.height * 0.09,
              margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Text('$topText',
                  style: TextStyle(
                    fontSize: 38,
                    color: Colors.white70,
                  ))),
          Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerRight,
              height: MediaQuery.of(context).size.height * 0.09,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: Text('$botText',
                  style: TextStyle(
                    fontSize: 38,
                    color: Colors.white70,
                  ))),
          Expanded(
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Table(
                  children: [
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "$degRad", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "sin", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "|x|", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("√", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("7", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("8", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("9", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("⌫", Colors.grey, Colors.black),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("AC", Colors.grey, Colors.black),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("π", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "cos", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "xⁿ", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "x²", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("4", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("5", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("6", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("÷", Colors.orange, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("×", Colors.orange, Colors.white),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("e", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "tan", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "eⁿ", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "lg", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("1", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("2", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("3", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("-", Colors.orange, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("+", Colors.orange, Colors.white),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "n!", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "ctg", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "ln", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "log", Colors.grey.shade900, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton("0", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton(
                            "00", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child:
                            calcButton(".", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("()", Colors.orange, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.125,
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.0125),
                        child: calcButton("=", Colors.orange, Colors.white),
                      ),
                    ])
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class SimpleCalculator extends StatefulWidget {
  const SimpleCalculator({Key? key}) : super(key: key);

  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  List bin = ['*', '/', '+', '-'];
  String topText = "";
  String botText = "";
  String lastChar = 'n';
  String degRad = 'RAD';
  double trigConst = 1;
  bool isPresent = false;
  bool isMinor = false;
  double result = 0.0;
  double beforeResult = 0.0;
  int bracketsCount = 0;

  double calcLog(double x, double y) {
    return log(x) / log(y);
  }

  String fact(String x) {
    var newX = double.parse(x).ceil();
    var res = 1.0;
    for (var i = 1; i <= newX; i++) {
      res *= i;
    }
    return res.toString();
  }

  double calculating(List<String> chars) {
    List out = [];
    List stack = [];
    for (var index = 0; index < chars.length; index++) {
      if (chars[index] == 'pi') {
        out.add(pi.toString());
      } else if (chars[index] == 'e') {
        out.add(e.toString());
      } else if (chars[index].runes.last - '0'.runes.last < 10 &&
          chars[index].runes.last - '0'.runes.last >= 0) {
        out.add(chars[index]);
      } else if (chars[index] == ')') {
        if (stack.length > 0)
          while (stack.length > 0 && stack.last != '(') {
            out.add(stack.removeLast());
          }
        stack.removeLast();
      } else if (chars[index] == '(')
        stack.add(chars[index]);
      else {
        if (stack.length > 0)
          while (stack.length > 0 &&
              stack.last != '(' &&
              (bin.indexOf(chars[index]) / 2 >= bin.indexOf(stack.last) / 2)) {
            out.add(stack.removeLast());
          }
        stack.add(chars[index]);
      }
    }
    out.addAll(stack.reversed);
    stack.clear();
    for (var i = 0; i < out.length; i++) {
      if (out[i].runes.last - '0'.runes.last < 10 &&
          out[i].runes.last - '0'.runes.last >= 0) {
        stack.add(double.parse(out[i]));
      } else {
        switch (out[i]) {
          case "*":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last * se;
            break;
          case "/":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last / se;
            break;
          case "+":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last + se;
            break;
          case "-":
            var se = stack.removeLast();
            stack[stack.length - 1] = stack.last - se;
            break;
        }
      }
    }
    return stack.last;
  }

  void precalculating() {
    var tempString = topText;
    tempString += ')' * bracketsCount;
    while (tempString.contains("()")) {
      tempString = tempString.replaceAll('()', '');
    }
    tempString = tempString
        .replaceAll('(', ' ( ')
        .replaceAll(')', ' ) ')
        .replaceAll('-', ' - ')
        .replaceAll('+', ' + ')
        .replaceAll('*', ' * ')
        .replaceAll('/', ' / ')
        .replaceAll('^', ' ^ ')
        .replaceAll('!', ' ! ');
    var splitString = tempString.split(" ");
    splitString.removeWhere((element) => element.length == 0);
    for (var i = 0; i < splitString.length; i++)
      if (splitString[i] == '!') {
        splitString[i - 1] = fact(splitString[i - 1]);
      }
    splitString.removeWhere((element) => element == '!');
    result = calculating(splitString);
    botText = result.toString();
    setState(() {});
    return;
  }

  void processing(String textButton) {
    switch (textButton) {
      case ".":
        if (!isMinor &&
            topText.runes.last - '0'.runes.last < 10 &&
            topText.runes.last - '0'.runes.last >= 0) {
          isMinor = true;
          topText += '.';
        }
        break;

      case '⌫':
        if (topText.endsWith(')')) bracketsCount++;
        if (topText.endsWith('(')) bracketsCount--;
        if (topText.endsWith('.')) isMinor = false;
        topText = topText.substring(0, topText.length - 1);
        break;
      case "÷":
        if (topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == ')') {
          isMinor = false;
          topText += '/';
        }
        break;
      case "-":
        if (topText.length == 0 ||
            topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == ')') {
          isMinor = false;
          topText += '-';
        }
        break;
      case "()":
        if (topText.length > 0 &&
            (topText.runes.last - '0'.runes.last < 10 &&
                    topText.runes.last - '0'.runes.last >= 0 ||
                topText.characters.last == ')') &&
            bracketsCount > 0) {
          isMinor = false;
          bracketsCount--;
          topText += ')';
        } else if (topText.length == 0 ||
            ((topText.runes.last - '0'.runes.last > 10 ||
                    topText.runes.last - '0'.runes.last < 0) &&
                topText.characters.last != ')')) {
          isMinor = false;
          bracketsCount++;
          topText += '(';
        }
        break;

      case "AC":
        result = 0;

        isMinor = false;
        topText = "";
        botText = "";
        result = 0;
        bracketsCount = 0;
        break;

      case "×":
        if (topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0 ||
            topText.characters.last == ')') {
          isMinor = false;
          topText += '*';
        }
        break;

      case "+":
        if ((topText.runes.last - '0'.runes.last < 10 &&
                topText.runes.last - '0'.runes.last >= 0) ||
            topText.characters.last == ')') {
          isMinor = false;
          topText += '+';
        }
        break;
      case "=":
        isMinor = false;
        topText = result.toString();
        break;
      default:
        if (topText.length == 0 || topText.characters.last != ')')
          topText += textButton;
    }
    setState(() {});
    precalculating();
    return;
  }

  Widget calcButton(String text, Color buttonColor, Color textColor) {
    return Container(
        child: FloatingActionButton(
      shape: CircleBorder(),
      backgroundColor: buttonColor,
      onPressed: () {
        processing(text);
      },
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 30),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerRight,
              height: MediaQuery.of(context).size.height * 0.08,
              margin: EdgeInsets.fromLTRB(10, 20, 20, 0),
              child: Text('$topText',
                  style: TextStyle(
                    fontSize: 38,
                    color: Colors.white70,
                  ))),
          Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(10, 20, 20, 0),
              child: Text('$botText',
                  style: TextStyle(
                    fontSize: 38,
                    color: Colors.white70,
                  ))),
          Expanded(
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Table(
                  children: [
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("AC", Colors.grey, Colors.black),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("⌫", Colors.grey, Colors.black),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("()", Colors.orange, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("÷", Colors.orange, Colors.white),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("7", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("8", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("9", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("×", Colors.orange, Colors.white),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("4", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("5", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("6", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("-", Colors.orange, Colors.white),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("1", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("2", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("3", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("+", Colors.orange, Colors.white),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton("0", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton(
                            "00", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child:
                            calcButton(".", Colors.grey.shade800, Colors.white),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        margin: EdgeInsets.all(10),
                        child: calcButton("=", Colors.orange, Colors.white),
                      ),
                    ])
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
