import 'dart:io';

void main() async {
  var socket = await Socket.connect("10.10.10.16", 9000);
  socket.add([0]);
  await socket.first;
  socket.close();
  exit(0);
}
