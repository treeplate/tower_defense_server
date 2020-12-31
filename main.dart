import 'dart:io';
import 'dart:async';

import 'world.dart';

void main() {
  print("Main()");
  runZoned(() {
    print("Running zoned");
    test();
  }, onError: (Object e, StackTrace st) {
    print("zone error $e, stack trace: $st");
  });
}

Future<void> test() async {
  try {
    int socketN = 0;
    Map<Socket, int> sockets = {};
    ServerSocket server =
        await ServerSocket.bind(InternetAddress.anyIPv4, 9000);
    void Function() callback;
    print("Creating world...");
    World world = World(
      3,
      3,
      {
        [1, 1]: 0,
      },
      () => callback()
    );
    print("Created world.");
    callback =       () {
        for(Socket client in sockets.keys) {
                    client.add([world.w, world.h] +
              world.world.entries
                  .map((MapEntry<List<int>, int> item) =>
                      item.key + [item.value])
                  .fold<List<int>>(
                      [], (List<int> prev, List<int> next) => prev + next));

        }
      };
    print("Created callBACK")


    server.listen((Socket socket) {
      print("Got socket.");
      socketN++;
      sockets[socket] = socketN;
      print("[${sockets[socket]}] Listening:");
      for (Socket client in sockets.keys) {
        client.add([world.w, world.h] +
            world.world.entries
                .map((MapEntry<List<int>, int> item) => item.key + [item.value])
                .fold<List<int>>(
                    [], (List<int> prev, List<int> next) => prev + next));
      }
      socket.listen((List<int> message) {
        print("[${sockets[socket]}] Got message ${message}");
        world.addTower(message);
        for (Socket client in sockets.keys) {
          client.add([world.w, world.h] +
              world.world.entries
                  .map((MapEntry<List<int>, int> item) =>
                      item.key + [item.value])
                  .fold<List<int>>(
                      [], (List<int> prev, List<int> next) => prev + next));
        }
        print("[${sockets[socket]}] Sent message");
      }, onError: (Object e, StackTrace st) {
        print("[${sockets[socket]}] error, $e stack: $st");
      }, onDone: () {
        print("[${sockets[socket]}] Socket done");
        sockets.remove(socket);
        print("Socket done: removed");
      }, cancelOnError: true);
    }, onDone: () {
      print("external done");
    }, onError: (Object e, StackTrace st) {
      print("oerror: $e, stack trace: $st");
    });
    print(".listened");
  } catch (e, st) {
    print("eerror: $e, stack trace: $st");
  }
}
