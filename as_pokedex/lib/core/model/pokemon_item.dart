import 'package:as_pokedex/core/constants.dart';

class PokemonItem {
  final String name;
  final String url;

  String get pokemonId {
    // Quebra a URL nas barras
    final urlSplitted = url.split('/');
    // Penúltimo elemento é o id
    String pokemonId = urlSplitted[urlSplitted.length - 2];

    if (pokemonId.length == 1) {
      pokemonId = '00' + pokemonId;
    } else if (pokemonId.length == 2) {
      pokemonId = '0' + pokemonId;
    }

    return pokemonId;
  }

  /// Coloca letra maiúscula no nome do Pokémon
  String get nameDisplay {
    return name.replaceFirst(name[0], name[0].toUpperCase());
  }

  /// Devolve a url da sprite do Pokémon
  String get spriteUrl {
    if (name.contains('-mega')) {
      return '$SPRITE_URL_MEGA/$pokemonId.png';
    } else {
      return '$SPRITE_URL/$pokemonId.png';
    }
  }

  const PokemonItem({this.name, this.url});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  factory PokemonItem.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return PokemonItem(
      name: map['name'],
      url: map['url'],
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is PokemonItem && o.pokemonId == pokemonId;
  }

  @override
  int get hashCode => pokemonId.hashCode;
}
