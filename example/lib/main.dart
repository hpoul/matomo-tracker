import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    Logger.root.level = Level.FINEST;
    Logger.root.onRecord.listen((LogRecord rec) {
      print(
        '[${rec.time}][${rec.level.name}][${rec.loggerName}] ${rec.message}',
      );
    });

    MatomoTracker.instance.initialize(
      siteId: 1,
      url: 'https://analytics.example.com/matomo.php',
    );
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matomo Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Matomo Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// Send an event to Matomo on widget creation.
class _MyHomePageState extends State<MyHomePage> with TraceableClientMixin {
  int _counter = 0;

  void _incrementCounter() {
    // Send an event to Matomo on tap.
    MatomoTracker.instance.trackEvent(
      name: 'IncrementCounter',
      action: 'Click',
    );
    setState(() {
      _counter++;
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
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  String get traceName => 'Created HomePage';

  @override
  String get traceTitle => widget.title;
}
