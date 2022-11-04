import 'package:flutter/material.dart';
import 'package:homeworks_cpmdwithf/search.dart';
import 'package:provider/provider.dart';

import 'jokes.dart';
import 'favourite.dart';
import 'models/favourite_storage.dart';
import 'search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const List<Tab> tabs = <Tab>[
    Tab(
      text: 'Jokes',
      icon: Icon(Icons.insert_emoticon_rounded),
    ),
    Tab(
      text: 'Favourites',
      icon: Icon(Icons.star),
    ),
    Tab(
      text: 'Search',
      icon: Icon(Icons.search),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Favourites>(
      create: (context) => Favourites(),
      child: MaterialApp(
        title: 'Tinder with Chuck!',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
        ),
        home: DefaultTabController(
          length: tabs.length,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: const SafeArea(
                child: TabBar(tabs: tabs),
              ),
            ),
            body: const TabBarView(
              // 'Jokes screen' uses swiping, so turn off swiping of tabs
              physics: NeverScrollableScrollPhysics(),
              children: [
                JokeScreen(),
                FavouriteScreen(),
                SearchScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
