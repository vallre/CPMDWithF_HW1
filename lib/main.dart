import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Joke {
  final String id;
  final String joke;
  final String url;

  const Joke({
    required this.id,
    required this.joke,
    required this.url,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: json['id'],
      joke: json['value'],
      url: json['url'],
    );
  }
}

Future<Joke> fetchJoke() async {
  final jokeResponse =
      await http.get(Uri.parse('https://api.chucknorris.io/jokes/random'));

  if (jokeResponse.statusCode == 200) {
    // If everything is OK -> return the joke stored in 'value'
    return Joke.fromJson(jsonDecode(jokeResponse.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load joke');
  }
}

launchGivenUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw 'Could not launch $url';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinder with Chuck!',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(title: 'Joke Screen'),
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
  // var to store the joke information
  late Future<Joke> _futureJoke;
  String _url = '';
  // var to control text animation
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Don't forget to get the first joke
    _futureJoke = fetchJoke();
  }

  void _generateJoke() {
    setState(() {
      _futureJoke = fetchJoke();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        // SafeArea to make sure the user can see the whole app without obstructions
        child: Center(
          child: SafeArea(
            top: false,
            bottom: false,
            minimum: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(48.0)),
                Text(
                  'Your Chuck Norris joke:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Padding(padding: EdgeInsets.all(40.0)),
                AnimatedSlide(
                  // AnimatedSlide with GestureDetector to allow the user to swipe right for a new joke
                  offset: _offset,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _offset = Offset(
                          max(-1, min(1, _offset.dx + 0.01 * details.delta.dx)),
                          _offset.dy);
                      setState(() {});
                    },
                    onPanEnd: (details) {
                      _offset = Offset.zero;
                      _generateJoke();
                    },
                    // convert Future<Joke> into Joke and process it
                    child: FutureBuilder<Joke>(
                      future: _futureJoke,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // if data has arrived, print it
                          // and save url
                          _url = snapshot.data!.url;
                          return Text(
                            snapshot.data!.joke,
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.center,
                          );
                        } else if (snapshot.hasError) {
                          // if there is an error, print it
                          return Text(
                            '${snapshot.error}',
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.center,
                          );
                        }
                        // if data did not arrive, wait for it
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(20.0)),
                Text(
                  'Also you can swipe the text left or right for a new joke!',
                  style: Theme.of(context).textTheme.overline,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateJoke,
        tooltip: 'Next joke',
        label: const Text('Next joke'),
        icon: const Icon(Icons.next_plan),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: 'Open in external browser',
              icon: const Icon(Icons.open_in_browser_rounded),
              onPressed: () {
                launchGivenUrl(_url);
              },
              alignment: Alignment.bottomLeft,
            ),
            const Text('Open in browser')
          ],
        ),
      ),
    );
  }
}
