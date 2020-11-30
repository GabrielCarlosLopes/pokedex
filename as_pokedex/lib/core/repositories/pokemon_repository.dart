import 'package:as_pokedex/core/constants.dart';
import 'package:as_pokedex/core/model/pokemon.dart';
import 'package:as_pokedex/core/model/pokemon_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonRepository {
  final String endpoint = 'pokemon';

  Future<List<PokemonItem>> getAll({int limit = 0, int offset = 1050}) async {
    final response =
        await http.get('$SERVER_URL/$endpoint?limit=$limit&offset=$offset');

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

    return (responseJson['results'] as List)
        .map((e) => PokemonItem.fromJson(e))
        .toList();
  }

  Future<Pokemon> getPokemon(String name) async {
    final response =
        await http.get('$SERVER_URL/$endpoint/${name.toLowerCase()}');

    final responseJson = jsonDecode(response.body);

    Pokemon pokemon;

    try {
      pokemon = Pokemon.fromJson(responseJson);
    } catch (e) {
      print(e);
    }

    return pokemon;
  }

  Future getEvolutions(String url) async {
    final response = await http.get(url);

    final responseJson = jsonDecode(response.body)['evolution_chain']['url'];

    final response2 = await http.get(responseJson.toString());

    final responseJson2 = jsonDecode(response2.body)['chain'];

    return responseJson2;
  }
}
