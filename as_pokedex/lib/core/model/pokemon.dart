import 'package:as_pokedex/core/constants.dart';

class Pokemon {
  List<Abilities> abilities;
  int height;
  int id;
  String name;
  Ability species;
  List<Stats> stats;
  List<Types> types;
  int weight;

  Pokemon(
      {this.abilities,
      this.height,
      this.id,
      this.name,
      this.species,
      this.stats,
      this.types,
      this.weight});

  String get spriteUrl {
    String pokemonId(String id) {
      if (id.length == 1) {
        return id = '00' + id;
      } else if (id.length == 2) {
        return id = '0' + id;
      }
      return id;
    }

    String id = species.url.substring(42);
    id = pokemonId(id.substring(0, id.length - 1));

    if (name.contains('-mega') && name.contains('-x')) {
      return '$SPRITE_URL/$id-mx.png';
    } else if (name.contains('-mega') && name.contains('-y')) {
      return '$SPRITE_URL/$id-my.png';
    } else if (name.contains('-mega')) {
      return '$SPRITE_URL/$id-m.png';
    } else {
      return '$SPRITE_URL/$id.png';
    }
  }

  String get spriteUrlShiny {
    String pokemonId = id.toString();
    if (pokemonId.length == 1) {
      pokemonId = '00' + pokemonId;
    } else if (pokemonId.length == 2) {
      pokemonId = '0' + pokemonId;
    }

    if (name.contains('-mega')) {
      return '$SPRITE_URL_MEGA/$pokemonId.png';
    } else {
      return '$SPRITE_URL_SHINY/$pokemonId.png';
    }
  }

  Pokemon.fromJson(Map<String, dynamic> json) {
    if (json['abilities'] != null) {
      abilities = new List<Abilities>();
      json['abilities'].forEach((v) {
        abilities.add(new Abilities.fromJson(v));
      });
    }
    height = json['height'];
    id = json['id'];
    name = json['name'];
    species =
        json['species'] != null ? new Ability.fromJson(json['species']) : null;
    if (json['stats'] != null) {
      stats = new List<Stats>();
      json['stats'].forEach((v) {
        stats.add(new Stats.fromJson(v));
      });
    }
    if (json['types'] != null) {
      types = new List<Types>();
      json['types'].forEach((v) {
        types.add(new Types.fromJson(v));
      });
    }
    weight = json['weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.abilities != null) {
      data['abilities'] = this.abilities.map((v) => v.toJson()).toList();
    }
    data['height'] = this.height;
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.species != null) {
      data['species'] = this.species.toJson();
    }
    if (this.stats != null) {
      data['stats'] = this.stats.map((v) => v.toJson()).toList();
    }
    if (this.types != null) {
      data['types'] = this.types.map((v) => v.toJson()).toList();
    }
    data['weight'] = this.weight;
    return data;
  }
}

class Abilities {
  Ability ability;
  bool isHidden;
  int slot;

  Abilities({this.ability, this.isHidden, this.slot});

  Abilities.fromJson(Map<String, dynamic> json) {
    ability =
        json['ability'] != null ? new Ability.fromJson(json['ability']) : null;
    isHidden = json['is_hidden'];
    slot = json['slot'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ability != null) {
      data['ability'] = this.ability.toJson();
    }
    data['is_hidden'] = this.isHidden;
    data['slot'] = this.slot;
    return data;
  }
}

class Ability {
  String name;
  String url;

  Ability({this.name, this.url});

  Ability.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['url'] = this.url;
    return data;
  }
}

class Stats {
  int baseStat;
  int effort;
  Ability stat;

  Stats({this.baseStat, this.effort, this.stat});

  Stats.fromJson(Map<String, dynamic> json) {
    baseStat = json['base_stat'];
    effort = json['effort'];
    stat = json['stat'] != null ? new Ability.fromJson(json['stat']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['base_stat'] = this.baseStat;
    data['effort'] = this.effort;
    if (this.stat != null) {
      data['stat'] = this.stat.toJson();
    }
    return data;
  }
}

class Types {
  int slot;
  Ability type;

  Types({this.slot, this.type});

  Types.fromJson(Map<String, dynamic> json) {
    slot = json['slot'];
    type = json['type'] != null ? new Ability.fromJson(json['type']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slot'] = this.slot;
    if (this.type != null) {
      data['type'] = this.type.toJson();
    }
    return data;
  }
}
