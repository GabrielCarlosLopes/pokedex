import 'package:as_pokedex/model/pokemon_item.dart';
import 'package:as_pokedex/pages/pokemon_detail.dart';
import 'package:as_pokedex/repositories/pokemon_repository.dart';
import 'package:flutter/material.dart';
import 'package:as_pokedex/extensions/color_helper.dart';
import 'package:palette_generator/palette_generator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController;

  PokemonRepository _pokemonRepository;

  /// Quantidade de pokémon por get
  int _pokemonListLimit = 1000;

  /// Quantidade de pokémon pulado por get
  int _pokemonListOffset = 0;

  List<PokemonItem> _pokemonList;
  List<PokemonItem> _pokemonListFiltred;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _pokemonRepository = PokemonRepository();

    _scrollController = ScrollController();
    _scrollController.addListener(_listenScrollController);

    _getAllPokemon();
  }

  void _getAllPokemon() async {
    // Se nunca carregou, usa o loader de tela inteira
    final withLoading = _pokemonList == null;

    if (withLoading) {
      setState(() => _isLoading = true);
    }

    final remoteList = await _pokemonRepository.getAll(
        limit: _pokemonListLimit, offset: _pokemonListOffset);

    // Adiciona 20 para "passar de página"
    _pokemonListOffset += 1000;

    final actualList = _pokemonList ?? [];
    // Soma as duas listas e remove duplicatas
    final newList = (actualList + remoteList).toSet().toList();

    setState(() {
      _isLoading = false;
      _pokemonList = newList;
      _pokemonListFiltred = _pokemonList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoader();
    } else {
      return _buildList();
    }
  }

  Widget _buildLoader() {
    return LinearProgressIndicator();
  }

  Widget _buildList() {
    if (_pokemonList == null) {
      return const SizedBox();
    }

    if (_pokemonList.isEmpty) {
      return Center(child: Text('Nenhum pokémon encontrado na grama alta'));
    }

    return ListView.separated(
      key: const PageStorageKey('myListView'),
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemCount: _pokemonListFiltred.length,
      itemBuilder: (context, index) {
        if (_pokemonList.length > index) {
          final pokemon = _pokemonListFiltred[index];

          return GestureDetector(
            child: _buildPokemonCard(pokemon),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetail(
                    nameSearch: pokemon.name,
                  ),
                ),
              );
            },
          );
        } else {
          return _buildBottomLoader();
        }
      },
    );
  }

  Widget _buildBottomLoader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: double.infinity,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPokemonCard(PokemonItem pokemon) {
    final imageProvider = NetworkImage(pokemon.spriteUrl);

    return FutureBuilder<Color>(
        future: _getMainColor(imageProvider),
        initialData: Colors.white,
        builder: (context, snapshot) {
          final cardColor = snapshot.data;
          return Card(
            margin: const EdgeInsets.all(0.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(4.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${pokemon.pokemonId}',
                          style: TextStyle(
                            color: cardColor.constrast(),
                          ),
                        ),
                        Text(
                          pokemon.nameDisplay,
                          style: TextStyle(
                            color: cardColor.constrast(),
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      _buildPokeBallImage(),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: NetworkImage(pokemon.spriteUrl),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _listenScrollController() {
    if (_scrollController.position.atEdge) {
      _getAllPokemon();
    }
  }

  Widget _buildPokeBallImage() {
    return Positioned.fill(
      right: 0.0,
      top: -10.0,
      bottom: -10.0,
      child: Transform.rotate(
        angle: 0.5,
        child: Opacity(
          opacity: 0.5,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/poke_ball.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Color> _getMainColor(ImageProvider imageProvider) async {
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);

    return paletteGenerator.dominantColor.color;
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Text(
        "Let's GO Flutter",
        style: const TextStyle(color: Colors.black),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: Container(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                hintText: 'Search Pokemon',
              ),
              onChanged: (value) {
                value = value.toLowerCase();
                setState(() {
                  _pokemonListFiltred = _pokemonList.where((poke) {
                    var pokeName = poke.name.toLowerCase();
                    return pokeName.contains(value);
                  }).toList();
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
