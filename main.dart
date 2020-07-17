import 'dart:io';
import 'dart:async';

void main() {
  runZoned(() {
    test();
  }, onError: (Object e, StackTrace st) {
    print("zone error $e, stack trace: $st");
  });
}

///0 = enemy
///1 = tower

Future<void> test() async {
  try {
    int socketN = 0;
    int w = 3;
    int h = 3;
    Map<List<int>, int> world = {[1, 1]: 0, [0, 0]: 1};                                                                                                                                      
    Map<Socket, int> sockets = {};
    ServerSocket server = await ServerSocket.bind(InternetAddress.anyIPv4, 9000);
    server.listen((Socket socket) {
      socketN++;
      sockets[socket] = socketN;
      print("[${sockets[socket]}] Listening:");
      for(Socket client in sockets.keys) {
        client.add([w, h] + world.entries.map((MapEntry<List<int>, int> item) => item.key + [item.value]).fold<List<int>>([], (List<int> prev, List<int> next) => prev+next));
      } 
      socket.listen((List<int> message) {
        print("[${sockets[socket]}] Got message ${message}");
        bool valid = true;
        for(List<int> key in world.keys) {
          if(key[0] == message[0] && key[1] == message[1]) {
            valid = false;
          }
        }
        if (valid) {
          world[message] = 1;
        }
        for(Socket client in sockets.keys) {
          client.add([w, h] + world.entries.map((MapEntry<List<int>, int> item) => item.key + [item.value]).fold<List<int>>([], (List<int> prev, List<int> next) => prev+next));
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
  } catch (e, st) {
    print("eerror: $e, stack trace: $st");
  }
}

