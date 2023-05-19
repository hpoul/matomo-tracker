import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

// See the docker folder for instructions on how to get a
// test Matomo instance running
const _matomoEndpoint = 'http://localhost:8765/matomo.php';
const _sideId = 1;
const _testUserId = 'Nelson Pandela';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MatomoTracker.instance.initialize(
    siteId: _sideId,
    url: _matomoEndpoint,
    verbosityLevel: Level.all,
  );
  MatomoTracker.instance.setVisitorUserId(_testUserId);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matomo Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Matomo Example'),
      navigatorObservers: [matomoObserver],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

/// Sends a page view to Matomo on widget creation by implementing TraceableClientMixin
class MyHomePageState extends State<MyHomePage> with TraceableClientMixin {
  int _counter = 0;

  void _incrementCounter() {
    // Send an event to Matomo on tap.
    // To signal that this event happend on this page, we use the
    // pvId of the page.
    MatomoTracker.instance.trackEvent(
      eventInfo: EventInfo(
        category: 'Main',
        action: 'Click',
        name: 'IncrementCounter',
      ),
      pvId: pvId,
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
            ContentWidget(
              pvId: pvId,
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OtherPage(),
                    ),
                  );
                },
                child: const Text('Go to OtherPage'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  String get actionName => widget.title;

  @override
  String? get path => '/homepage';
}

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TraceableWidget(
      path: '/otherpage',
      actionName: 'Other Page',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Other Page'),
        ),
        body: const Center(
          child: Text(
            'Welcome to the other page!',
          ),
        ),
      ),
    );
  }
}

class ContentWidget extends StatefulWidget {
  final String? pvId;
  const ContentWidget({
    super.key,
    this.pvId,
  });

  @override
  State<ContentWidget> createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  late bool _closed;
  final Content _exampleContent = Content(
    name: 'Matomo is great',
    piece: 'banner',
  );

  @override
  void initState() {
    super.initState();
    _closed = false;
    MatomoTracker.instance.trackContentImpression(
      content: _exampleContent,
      pvId: widget.pvId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: !_closed,
        child: Card(
            color: Colors.blue,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _close,
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
                const SizedBox(
                  width: 200,
                  height: 150,
                  child: Center(
                    child: Text(
                      'Matomo is great!',
                    ),
                  ),
                )
              ],
            )));
  }

  void _close() {
    setState(() {
      _closed = true;
    });
    MatomoTracker.instance.trackContentInteraction(
      interaction: 'close',
      content: _exampleContent,
      pvId: widget.pvId,
    );
  }
}
