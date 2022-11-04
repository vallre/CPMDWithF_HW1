import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/favourite_storage.dart';
import 'models/search_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  final String title = 'Search for a joke';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // search bar controller
  late TextEditingController _controller;
  // var to keep track of searched jokes
  List _jokeList = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // function to search for jokes given a search query
  void _searchJoke(String query) {
    searchJoke(query).then((jokeListMap) {
      _jokeList = jokeListMap;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 10)),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your search term',
              ),
              onSubmitted: (String value) async {
                // searchJoke('Money').then((value) => print(value[0]['value']));
                _searchJoke(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Searching...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _jokeList.length,
                itemBuilder: (BuildContext context, int index) =>
                    SearchItemTile(
                        _jokeList[index]['id'], _jokeList[index]['value']),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchItemTile extends StatelessWidget {
  final String itemID;
  final String item;

  const SearchItemTile(this.itemID, this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    // watch for saved favourite jokes
    final favouritesList = context.watch<Favourites>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(item),
        trailing: IconButton(
          icon: const Icon(Icons.star),
          onPressed: () {
            if (itemID != '') {
              !favouritesList.containsKey(itemID)
                  ? favouritesList.add(itemID, item)
                  : favouritesList.remove(itemID);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(favouritesList.containsKey(itemID)
                      ? 'Added to favorites.'
                      : 'Removed from favorites.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
