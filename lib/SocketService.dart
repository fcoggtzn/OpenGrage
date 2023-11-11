import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
///import 'dart:io';
// import 'dart:convert';
//
// void main() {
//   int port = 8082;
//
//   // listen forever & send response
//   RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
//     socket.listen((RawSocketEvent event) {
//       if (event == RawSocketEvent.read) {
//         Datagram dg = socket.receive();
//         if (dg == null) return;
//         final recvd = String.fromCharCodes(dg.data);
//
//         /// send ack to anyone who sends ping
//         if (recvd == "ping") socket.send(Utf8Codec().encode("ping ack"), dg.address, port);
//         print("$recvd from ${dg.address.address}:${dg.port}");
//       }
//     });
//   });
//   print("udp listening on $port");
//
//   // send single packet then close the socket
//   RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
//     socket.send(Utf8Codec().encode("single send"), InternetAddress("192.168.1.19"), port);
//     socket.listen((event) {
//       if (event == RawSocketEvent.write) {
//         socket.close();
//         print("single closed");
//       }
//     });
//   });
//
// }
///
 class SocketService {
   Socket? socket;
   List receiveQueue= [];
   String host;
   int port;

   SocketService({this.host="192.168.0.100",this.port=1234});

   Future<void> setupSocket() async {

     RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
     socket.listen((RawSocketEvent event) {
       if (event == RawSocketEvent.read) {
         Datagram? dg = socket.receive();
        if (dg == null) return;
         final recvd = String.fromCharCodes(dg.data);
         receiveQueue.add(recvd);

//         /// send ack to anyone who sends ping
         if (recvd == "ping") socket.send(Utf8Codec().encode("ping ack"), dg.address, port);
         print("$recvd from ${dg.address.address}:${dg.port}");
       }
     });
   });
   /* socket = await Socket.connect(host, port);
     if(socket != null){
     socket!.listen(
           (Uint8List data) {
         final serverResponse = String.fromCharCodes(data);
         receiveQueue.add(serverResponse);
         print("socket!.write(data);");

       },

       // handle errors
       onError: (error) {
         print(error);
         socket!.destroy();
       },

       // handle server ending connection
       onDone: () {
         print('Server left.');
         socket!.destroy();
       },
     );
   }*/
   }

   void sendPayload(String data, {dynamic callback } ) async  {
     RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
     socket.send(Utf8Codec().encode(data), InternetAddress(host), port);
     socket.listen((event) {
       if (event == RawSocketEvent.read) {
         Datagram? dg = socket.receive();
         socket.close();
         if (dg == null) return;
         String dataReceived =String.fromCharCodes(dg.data);
         print( dataReceived);
         if (callback != null) {
            callback(jsonDecode(dataReceived) as Map<String, dynamic>);
         }

       }
       if (event == RawSocketEvent.write) {
         print("Payload send: $data");
       }
     });
   });
  /* if (socket == null ){
      await setupSocket();
      socket!.write(data);


   }
   else
   { socket!.write(data);}
*/

   }

   String getMessage() => receiveQueue.isNotEmpty? receiveQueue.removeLast():"";



 }