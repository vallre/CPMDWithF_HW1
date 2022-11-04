import 'dart:convert';

import 'package:http/http.dart' as http;

searchJoke(String query) async {
  http.Response jokeResponse;

  jokeResponse = await http
      .get(Uri.parse('https://api.chucknorris.io/jokes/search?query=$query'));

  if (jokeResponse.statusCode == 200) {
    // If everything is OK -> return the joke stored in 'value'
    return jsonDecode(jokeResponse.body)['result'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to search for a joke');
  }
}
