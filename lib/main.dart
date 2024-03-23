import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ruthapp/models/products_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ProductsModel> productsList = [];

  getProducts() async {
    productsList.clear();
    var client = http.Client();
    try {
      var response = await client.get(
        Uri.https('dummyjson.com', '/products'),
      );

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        productsList = (decodedResponse['products'] as List)
            .map((e) => ProductsModel.fromJson(e))
            .toList();
      });
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,

        body: RefreshIndicator(
          backgroundColor: Colors.deepPurple,
          color: Colors.white,
          onRefresh: () async {
            getProducts();
          },
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Products',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 22),
                    ),
                  ),
                  if (productsList.isNotEmpty)
                    for (int i = 0; i < productsList.length; i++)
                      productCard(productsList[i]),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getProducts();
          },
          tooltip: 'Increment',
          child: const Icon(Icons.refresh),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Widget productCard(ProductsModel item) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.network(
            item.thumbnail ?? "",
            width: MediaQuery.of(context).size.width / 2.6,
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? "",
                    style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                  Text(
                    item.category ?? "",
                    style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    item.description ?? "",
                    maxLines: 2,
                    style: const TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
