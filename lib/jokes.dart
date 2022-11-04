import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/favourite_storage.dart';
import 'models/joke_model.dart';

class JokeScreen extends StatefulWidget {
  const JokeScreen({super.key});

  final String title = 'Joke Screen';

  @override
  State<JokeScreen> createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  // var to store the joke information
  late Future<Joke> _futureJoke;
  String _url = '';
  String _id = '';
  String _joke = '';

  // var to control text animation
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Don't forget to get the first joke
    _futureJoke = fetchJoke();
  }

  // function to fetch a new joke from the current category
  void _generateJoke() {
    setState(() {
      _futureJoke = fetchJoke();
    });
  }

  // function to change the category and fetch a new joke
  void _changeAndGenerateJoke(String category) {
    setState(() {
      setCategory(category);
      _futureJoke = fetchJoke();
    });
  }

  @override
  Widget build(BuildContext context) {
    // var to keep track of current favourites
    final favouritesList = context.watch<Favourites>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // leading is dropdown menu to choose joke category
        leading: DecoratedBox(
          decoration: BoxDecoration(
              //background color of dropdown button
              color: Colors.white,
              //border of dropdown button
              border: Border.all(color: Colors.deepOrange, width: 3),
              boxShadow: const <BoxShadow>[
                //apply shadow on Dropdown button
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5),
              ]),
          child: Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
            child: DropdownButton<String>(
              value: getCategory(),
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              alignment: AlignmentDirectional.center,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(),
              onChanged: (String? value) {
                // This is called when the user selects an item from dropdown menu
                setState(() {
                  _changeAndGenerateJoke(value!);
                });
              },
              items:
                  jokeCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        leadingWidth: 89.0,
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
                          _id = snapshot.data!.id;
                          _joke = snapshot.data!.joke;
                          return Text(
                            _joke,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Open in external browser',
                    icon: const Icon(Icons.open_in_browser_rounded),
                    onPressed: () {
                      if (_url != '') {
                        launchGivenUrl(_url);
                      }
                    },
                    alignment: Alignment.bottomLeft,
                  ),
                  const Text('Open in browser')
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Save the current joke to your favourite list',
                    icon: const Icon(Icons.star),
                    onPressed: () {
                      if (_id != '') {
                        !favouritesList.containsKey(_id)
                            ? favouritesList.add(_id, _joke)
                            : favouritesList.remove(_id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(favouritesList.containsKey(_id)
                                ? 'Added to favorites.'
                                : 'Removed from favorites.'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    alignment: Alignment.bottomRight,
                  ),
                  const Text('Save to favourites')
                ],
              ),
            ],
          )),
    );
  }
}
