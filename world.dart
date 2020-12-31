import 'dart:async';

///0 = enemy
///1 = tower
class World {
  World(this.w, this.h, this.world, void Function() callback) {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      List<List<int>> todo = [];
      for (MapEntry<List<int>, int> entry in world.entries) {
        if (entry.value == 1) {
          List<List<int>> possible = surrounded(entry.key);
          List<int> working = world.keys
              .firstWhere((element) => possible.any((element2) =>
                  element2[0] == element[0] &&
                  element2[1] == element[1] &&
                  world[element] == 0), orElse: () => null);
         //print(working);
         if(working != null) todo.add(working);
        }
      }
      for(List<int> thing in todo) world.remove(thing);
      callback();
    });
  }
  void addTower(List<int> at) {
    bool valid = true;
    for (List<int> key in world.keys) {
      if (key[0] == at[0] && key[1] == at[1]) {
        valid = false;
      }
    }
    if (valid) {
      world[at] = 1;
    }
  }

  final int w;
  final int h;
  final Map<List<int>, int> world;
}

List<List<int>> surrounded(List<int> pos) {
  return [
    [pos[0] + 1, pos[1]],
    [pos[0] + 1, pos[1] + 1],
    [pos[0] + 1, pos[1] - 1],
    [pos[0] - 1, pos[1]],
    [pos[0] - 1, pos[1] + 1],
    [pos[0] - 1, pos[1] - 1],
    [pos[0], pos[1] + 1],
    [pos[0], pos[1] - 1],
  ];
}
