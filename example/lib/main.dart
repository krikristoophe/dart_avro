import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_avro/flutter_avro.dart';
import 'package:http/http.dart' as http;


const String accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X3R5cGUiOiJ1c2VyIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6MjY4LCJpYXQiOjE3MjQ1OTgxMzksImV4cCI6MTcyNDU5ODczOX0.ERaDlq21tjY0U8ht45tlADN5pewXCRkpBzBMFRIpMo8';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<(String, Uint8List)> fetch() async {
    final response = await http.get(Uri.parse('http://192.168.1.178:3333/sync'), headers: {
      'Authorization': 'Bearer $accessToken',
      'XClientId': '2',
      'x-result-format': 'application/avro',
    });
    final String schema = utf8.decode(base64Decode(response.headers['x-avro-schema']!));

    return (schema, response.bodyBytes);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final (schema, body) = await fetch();
              await FlutterAvro().decode(schema, body);
            },
            child: const Text('decode'),
          ),
        ),
      ),
    );
  }
}
