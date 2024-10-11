import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _hourController = TextEditingController(text: '25');
  final _minuteController = TextEditingController(text: '00');
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;

  static const twentyFiveMinutes = 1500;
  late int totalSeconds;
  bool isRunning = false;
  int totalPomodoros = 0;
  late Timer timer;
  String? errorMessage = "";

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {});
    timer.cancel();
    initPrefs();

    super.initState();
  }

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('hourTime') != null) {
      _hourController.text = prefs.getString('hourTime') ?? '25';
    }
    if (prefs.getString('minuteTime') != null) {
      _hourController.text = prefs.getString('minuteTime') ?? '00';
    }
  }

  void prefsWrite(String hourTime, String minuteTime) async {
    await prefs.setString('hourTime', hourTime);
    await prefs.setString('minuteTime', minuteTime);
  }

  void onStartPressed() {
    setState(() {
      errorMessage = "";
    });
    //유효성 측정
    if (_formKey.currentState?.validate() == false) {
      return;
    } else {
      //공백으로 넣었을 경우 0으로 처리
      _hourController.text =
          _hourController.text.isEmpty ? '0' : _hourController.text;
      _minuteController.text =
          _minuteController.text.isEmpty ? '00' : _minuteController.text;
    }
    prefsWrite(_hourController.text, _minuteController.text);

    //포커스 언포커스
    FocusScope.of(context).unfocus();

    //전체 시간 초로 바꾸기
    totalSeconds = int.parse(_hourController.text) * 60 +
        int.parse(_minuteController.text);

    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
    setState(() {
      isRunning = true;
    });
  }

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      setState(() {
        totalPomodoros += 1;
        isRunning = false;
        totalSeconds = twentyFiveMinutes;
      });
      timer.cancel();
    } else {
      setState(() {
        totalSeconds += -1;
        _hourController.text = (totalSeconds ~/ 60).toString();
        _minuteController.text = (totalSeconds % 60).toString().padLeft(2, '0');
      });
    }
  }

  void onPausePressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void onStopPressed() {
    setState(() {
      errorMessage = "";
    });
    timer.cancel();
    if (isRunning == true) {
      isRunning = false;
    }
    setState(() {
      totalPomodoros = 0;
/*
      _hourController.text = prefs.getString('hourTime') ?? '25';
      _minuteController.text = prefs.getString('minuteTime') ?? '00';
      totalSeconds = int.parse(_hourController.text) * 60 +
          int.parse(_minuteController.text);
          */
      _hourController.text = prefs.getString('hourTime') ?? '25';
      _minuteController.text = prefs.getString('minuteTime') ?? '00';
      totalSeconds = int.parse(_hourController.text) * 60 +
          int.parse(_minuteController.text);
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hourController,
                          textAlign: TextAlign.end,
                          autovalidateMode: AutovalidateMode.disabled,
                          decoration: const InputDecoration(
                            helperText: "",
                            errorBorder: InputBorder.none,
                            errorText: null,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontSize: 89,
                            fontWeight: FontWeight.w600,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              value = '0';
                            } else if (int.tryParse(value) == null) {
                              setState(() {
                                errorMessage = "정수값만 입력해야 합니다.";
                              });
                              return '';
                            } else if (int.parse(value) > 60) {
                              setState(() {
                                errorMessage = "시간 설정은 60분을 초과할 수 없습니다.";
                              });
                              return '';
                            }

                            return null;
                          },
                        ),
                      ),
                      Text(
                        ":",
                        style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontSize: 89,
                            fontWeight: FontWeight.w600,
                            height: -0.3),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _minuteController,
                          autovalidateMode: AutovalidateMode.disabled,
                          decoration: const InputDecoration(
                            helperText: "",
                            border: InputBorder.none,
                            errorText: null,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontSize: 89,
                            fontWeight: FontWeight.w600,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              value = '00';
                            } else if (int.tryParse(value) == null) {
                              setState(() {
                                errorMessage = "정수값만 입력해야 합니다.";
                              });
                              return '';
                            } else if (int.parse(value) > 59) {
                              setState(() {
                                errorMessage = "초 설정은 59초를 초과할 수 없습니다.";
                              });
                              return '';
                            }

                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: Text(
                errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: Theme.of(context).cardColor,
                      iconSize: 150,
                      onPressed: isRunning ? onPausePressed : onStartPressed,
                      icon: Icon(
                        isRunning
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                    ),
                    IconButton(
                      color: Theme.of(context).cardColor,
                      iconSize: 150,
                      onPressed: onStopPressed,
                      icon: const Icon(Icons.stop_circle_outlined),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          //borderRadius: BorderRadius.circular(50),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(
                                50,
                              ))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Pomodoros",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color,
                            ),
                          ),
                          Text(
                            '$totalPomodoros',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
