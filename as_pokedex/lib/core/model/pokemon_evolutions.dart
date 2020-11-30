class PokemonEvolutions {
  String name;
  String sprite;

  PokemonEvolutions({this.name, this.sprite});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sprite': sprite,
    };
  }

  factory PokemonEvolutions.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return PokemonEvolutions(
      name: map['name'],
      sprite: map['sprite'],
    );
  }
}
