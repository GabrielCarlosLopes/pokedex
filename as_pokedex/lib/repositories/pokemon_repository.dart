import 'package:as_pokedex/core/constants.dart';
import 'package:as_pokedex/model/pokemon.dart';
import 'package:as_pokedex/model/pokemon_item.dart';
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

    final Pokemon pokemon = Pokemon.fromJson(responseJson);

    return pokemon;
  }
}
