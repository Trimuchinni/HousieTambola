import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Housie Game',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentNumber = 0;
  List<bool> _isNumberSelectedList = List.generate(90, (index) => false);
  Set<int>? _selectedNumbers;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String currentNUmberString = 'Current Number: 0';
  bool checkSound = true;
  @override
  void initState() {
    super.initState();
    _selectedNumbers = {};
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 1.0, end: 1.5).animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            }
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateRandomNumber() {
    if (_selectedNumbers?.length == 90) {
      currentNUmberString = 'All numbers generated';
    } else {
      int randomNumber = Random.secure().nextInt(90) + 1;
      while (_selectedNumbers!.contains(randomNumber)) {
        randomNumber = Random.secure().nextInt(90) + 1;
      }
      _currentNumber = randomNumber;
      _isNumberSelectedList[randomNumber - 1] = true;
      _selectedNumbers!.add(randomNumber);
      _animationController.forward(from: 0.0);
      currentNUmberString = 'Current Number: $_currentNumber';
      if (checkSound) {
        speakNumber(_currentNumber);
      }
    }

    setState(() {});
  }

  Future<void> speakNumber(int number) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.speak(number.toString());
  }

  void _resetNumbers() {
    currentNUmberString = 'Current Number: 0';
    _selectedNumbers = {};
    _isNumberSelectedList = List.generate(90, (index) => false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Housie Game'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              currentNUmberString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _generateRandomNumber,
                  child: Text('Pick'),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Colors.orange),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (checkSound) {
                      checkSound = false;
                    } else {
                      checkSound = true;
                    }
                    setState(() {});
                  },
                  child: Text('Sound'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    primary: checkSound ? Colors.orange : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: _resetNumbers,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Colors.orange),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: (MediaQuery.of(context).size.height / 2) -
                  0.15 * (MediaQuery.of(context).size.height / 2),
              color: Colors.brown,
              child: GridView.count(
                // physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 10,
                childAspectRatio: 1.0,
                children: List.generate(90, (index) {
                  int number = index + 1;
                  return Transform.scale(
                    scale: _isNumberSelectedList[number - 1] &&
                            _currentNumber == number
                        ? _animation.value
                        : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: _isNumberSelectedList[number - 1]
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Text(
              'The numbers are:',
              style: TextStyle(fontSize: 30),
            ),
            // Text(_selectedNumbers?.length != null
            //     ? _selectedNumbers!.join('->')
            //     : ''),
            Expanded(
              // height: 30,
              child: GridView.count(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                crossAxisCount: 10,
                children: _selectedNumbers?.length != null
                    ? _selectedNumbers!
                        .toList()
                        .reversed
                        .toList()
                        .map((int number) => Container(
                              margin: EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 20,
                                ),
                              ),
                            ))
                        .toList()
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
