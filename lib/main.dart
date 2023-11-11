import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tcp_udp_socket/SocketService.dart';


void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Fggn Socket Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counterClose = 0;
  int _counterOpen = 0;
  Timer? _timer;
  dynamic systemPayload;
  int get doorStatusI => (systemPayload != null) ? systemPayload["system"]["door"]["status"] : 0;
  Icon get doorIcon =>  doorStatusI == 1?const Icon(Icons.lock_open) :const Icon(Icons.block);


  final SocketService socketService = SocketService();

  @override
  initState() {
    super.initState();
      const oneSec = Duration(seconds: 5);
      _timer = Timer.periodic(oneSec,
              (Timer timer) {
            print(" Polling for update 5 sec");
            socketService.sendPayload('{command:1}',callback: (systemPayload)
            { int doorStatusInt = doorStatusI;
              this.systemPayload = systemPayload;
              if (doorStatusI != doorStatusInt) {
                setState(() {
                  print("Update UI");
                });
              }
            });
          });
    print("initState Called");
  }

  void _closeDoor() {
    setState(() {
      _counterClose++;
      socketService.sendPayload('{"system":{"door":{"status":0}}');
    });
  }
  void _openDoor() {
    setState(() {
      _counterOpen++;
      socketService.sendPayload('{"system":{"door":{"status":1}}');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            doorIcon,
            const Text(
              'Open/ Closed door:',
            ),
            Text(
              '$_counterOpen / $_counterClose',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton:
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
       children: [
         FloatingActionButton(
        onPressed: _closeDoor,
        tooltip: 'Close door',
        child: const Icon(Icons.block),
      ),
       const SizedBox(width: 100,)
       ,
       FloatingActionButton(
        onPressed: _openDoor,
        tooltip: 'Open door',
        child: const Icon(Icons.lock_open),
      ),]),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
