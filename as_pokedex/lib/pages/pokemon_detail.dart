import 'package:as_pokedex/model/pokemon.dart';
import 'package:as_pokedex/repositories/pokemon_repository.dart';
import 'package:flutter/material.dart';

class PokemonDetail extends StatefulWidget {
  final String nameSearch;

  const PokemonDetail({Key key, this.nameSearch}) : super(key: key);

  @override
  _PokemonDetailState createState() {
    return _PokemonDetailState(this.nameSearch);
  }
}

class _PokemonDetailState extends State<PokemonDetail> {
  String nameSearch;
  Pokemon pokemonDetail;
  PokemonRepository _pokemonRepository;

  _PokemonDetailState(this.nameSearch);

  void getPokemon(String name) async {
    final pokemon = await _pokemonRepository.getPokemon(name);

    setState(() {
      pokemonDetail = pokemon;
    });
  }

  Future<Pokemon> setPokemon(String name) async {
    final pokemon = await _pokemonRepository.getPokemon(name);

    return pokemon;
  }

  @override
  void initState() {
    _pokemonRepository = PokemonRepository();
    getPokemon(widget.nameSearch);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameSearch),
      ),
      body: FutureBuilder(
        future: setPokemon(widget.nameSearch),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 5,
                ),
              );
            default:
              if (snapshot.hasData)
                return Container(
                  child: Text(pokemonDetail.name),
                );
              else
                return Container(
                  child: Center(
                    child: Text(
                      'erro',
                    ),
                  ),
                );
          }
        },
      ),
    );
  }
}
