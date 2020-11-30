import 'package:as_pokedex/core/contants_color.dart';
import 'package:as_pokedex/core/model/pokemon.dart';
import 'package:as_pokedex/core/model/pokemon_evolutions.dart';
import 'package:as_pokedex/core/repositories/pokemon_repository.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';

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
  List<Types> types;
  MultiTrackTween _animation;
  PageController _pageController = PageController(initialPage: 0);
  Color bodyColor;
  NetworkImage pokemonImage;
  List<PokemonEvolutions> evolutions = [];

  _PokemonDetailState(this.nameSearch);

  void getPokemon(String name) async {
    final pokemon = await _pokemonRepository.getPokemon(name);

    final listEvos =
        await _pokemonRepository.getEvolutions(pokemon.species.url);

    final List<PokemonEvolutions> evosHTTP = [];
    final evo1 = await _pokemonRepository.getPokemon(
      listEvos['species']['name'],
    );
    evosHTTP.add(PokemonEvolutions(name: evo1.name, sprite: evo1.spriteUrl));

    if (listEvos['evolves_to'].toString() != '[]') {
      final evo2 = await _pokemonRepository
          .getPokemon(listEvos['evolves_to'][0]['species']['name']);

      evosHTTP.add(PokemonEvolutions(name: evo2.name, sprite: evo2.spriteUrl));
      if (listEvos['evolves_to'][0]['evolves_to'].toString() != '[]') {
        final evo3 = await _pokemonRepository.getPokemon(
            listEvos['evolves_to'][0]['evolves_to'][0]['species']['name']);
        evosHTTP
            .add(PokemonEvolutions(name: evo3.name, sprite: evo3.spriteUrl));
      }
    }

    setState(() {
      bodyColor = ConstantsColor.getColorType(
        type: pokemon.types[0].type.name,
      );
      pokemonDetail = pokemon;
      evolutions = evosHTTP;
    });
  }

  Future<NetworkImage> setImagePokemon(Pokemon pokemon) async {
    final image = NetworkImage(pokemon.spriteUrl);

    return image;
  }

  @override
  void initState() {
    _pokemonRepository = PokemonRepository();
    getPokemon(widget.nameSearch);
    setState(() {
      _animation = MultiTrackTween([
        Track("rotation").add(
            Duration(seconds: 8),
            Tween(
              begin: 0.0,
              end: 8,
            ),
            curve: Curves.linear)
      ]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bodyColor,
      ),
      body: FutureBuilder(
        future: setImagePokemon(pokemonDetail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(
                child: Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 5,
                  ),
                ),
              );
            default:
              if (snapshot.hasData)
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopBody(),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.775,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: PageView(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        children: [
                          _infosTab(),
                          _statusTab(),
                          _evolutionTab(),
                        ],
                      ),
                    ),
                  ],
                );
              else
                return Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 5,
                    ),
                  ),
                );
          }
        },
      ),
    );
  }

  Widget _buildTopBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ControlledAnimation(
              playback: Playback.LOOP,
              duration: _animation.duration,
              tween: _animation,
              builder: (context, animation) {
                return Transform.rotate(
                  angle: animation['rotation'],
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/poke_ball.png',
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                  ),
                );
              }),
          Container(
            height: MediaQuery.of(context).size.height / 4.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: NetworkImage(pokemonDetail.spriteUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infosTab() {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Informações',
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Colors.grey[700],
                fontSize: MediaQuery.of(context).size.width / 13,
              ),
            ),
            _infoRow('nome', pokemonDetail.name),
            _infoRow('altura', pokemonDetail.height.toString()),
            _infoRow('peso', pokemonDetail.weight.toString()),
            Expanded(
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pokemonDetail.types.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ConstantsColor.getColorType(
                                type: pokemonDetail.types[index].type.name),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              pokemonDetail.types[index].type.name.replaceFirst(
                                pokemonDetail.types[index].type.name[0],
                                pokemonDetail.types[index].type.name[0]
                                    .toUpperCase(),
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Rubik',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String info, String dado) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              info.replaceFirst(info[0], info[0].toUpperCase()),
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Colors.grey[700],
                fontSize: MediaQuery.of(context).size.width / 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              dado.replaceFirst(dado[0], dado[0].toUpperCase()),
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width / 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTab() {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Colors.grey[700],
                fontSize: MediaQuery.of(context).size.width / 13,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 20),
            _statusIndicator(
              pokemonDetail.stats[0].stat.name.toUpperCase(),
              pokemonDetail.stats[0].baseStat.toString(),
            ),
            SizedBox(height: 10),
            _statusIndicator(
              pokemonDetail.stats[1].stat.name.replaceFirst(
                  pokemonDetail.stats[1].stat.name[0],
                  pokemonDetail.stats[1].stat.name[0].toUpperCase()),
              pokemonDetail.stats[1].baseStat.toString(),
            ),
            SizedBox(height: 10),
            _statusIndicator(
              pokemonDetail.stats[2].stat.name.replaceFirst(
                  pokemonDetail.stats[2].stat.name[0],
                  pokemonDetail.stats[2].stat.name[0].toUpperCase()),
              pokemonDetail.stats[2].baseStat.toString(),
            ),
            SizedBox(height: 10),
            _statusIndicator(
              'Sp. Attack',
              pokemonDetail.stats[3].baseStat.toString(),
            ),
            SizedBox(height: 10),
            _statusIndicator(
              'Sp. Defense',
              pokemonDetail.stats[4].baseStat.toString(),
            ),
            SizedBox(height: 10),
            _statusIndicator(
              pokemonDetail.stats[5].stat.name.replaceFirst(
                  pokemonDetail.stats[5].stat.name[0],
                  pokemonDetail.stats[5].stat.name[0].toUpperCase()),
              pokemonDetail.stats[5].baseStat.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIndicator(String title, String power) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Colors.grey[700],
                fontSize: MediaQuery.of(context).size.width / 20,
              ),
            ),
          ),
          SizedBox(width: 5),
          Text(
            power,
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width / 20,
            ),
          ),
          SizedBox(width: 5),
          LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 250,
              animation: true,
              lineHeight: 10.0,
              animationDuration: 800,
              percent: (int.tryParse(power) / 100) >= 1.0
                  ? 1.0
                  : (int.tryParse(power) / 100),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: ConstantsColor.getColorType(
                  type: pokemonDetail.types[0].type.name)),
        ],
      ),
    );
  }

  Widget _evolutionTab() {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Evoluções',
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Colors.grey[700],
                fontSize: MediaQuery.of(context).size.width / 20,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 7.5,
              ),
              child: _buildPokemonEvolution(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonEvolution() {
    List<Widget> getList() {
      List<Widget> lista = [];
      if (evolutions.length == 1) {
        lista.add(
          buildPokemonEvolution(
            MediaQuery.of(context).size.width / 2.5,
            MediaQuery.of(context).size.height / 2.5,
            evolutions[0].sprite,
            evolutions[0].name,
          ),
        );
      } else if (evolutions.length > 1 && evolutions.length < 3) {
        lista.add(
          buildPokemonEvolution(
            MediaQuery.of(context).size.width / 3,
            MediaQuery.of(context).size.height / 3,
            evolutions[0].sprite,
            evolutions[0].name,
          ),
        );
        lista.add(Icon(Icons.arrow_right_alt, color: Colors.black));
        lista.add(
          buildPokemonEvolution(
            MediaQuery.of(context).size.width / 3,
            MediaQuery.of(context).size.height / 3,
            evolutions[1].sprite,
            evolutions[1].name,
          ),
        );
      } else if (evolutions.length > 2) {
        lista.add(
          buildPokemonEvolution(
            MediaQuery.of(context).size.width / 5,
            MediaQuery.of(context).size.height / 5,
            evolutions[0].sprite,
            evolutions[0].name,
          ),
        );
        lista.add(Icon(Icons.arrow_right_alt, color: Colors.black));
        lista.add(
          buildPokemonEvolution(
            MediaQuery.of(context).size.width / 5,
            MediaQuery.of(context).size.height / 5,
            evolutions[1].sprite,
            evolutions[1].name,
          ),
        );
        lista.add(Icon(Icons.arrow_right_alt, color: Colors.black));
        lista.add(
          buildPokemonEvolution(
            MediaQuery.of(context).size.width / 5,
            MediaQuery.of(context).size.height / 5,
            evolutions[2].sprite,
            evolutions[2].name,
          ),
        );
      }

      return lista;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: getList(),
    );
  }

  Widget buildPokemonEvolution(
      double width, double height, String url, String name) {
    return Column(
      children: [
        Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(url),
            ),
          ),
        ),
        Text(
          name.replaceFirst(name[0], name[0].toUpperCase()),
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: MediaQuery.of(context).size.width / 25,
          ),
        ),
      ],
    );
  }
}
