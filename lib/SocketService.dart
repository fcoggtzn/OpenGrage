import 'dart:convert';
import 'dart:io';

 class SocketService {
   Socket? socket;
   List receiveQueue= [];
   String host;
   int port;

   SocketService({this.host="148.211.156.115",this.port=1234});



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


   }

   String getMessage() => receiveQueue.isNotEmpty? receiveQueue.removeLast():"";



 }