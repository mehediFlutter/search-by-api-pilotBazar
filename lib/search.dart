import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pilot_search/products.dart';

class PilotSearch extends StatefulWidget {
  const PilotSearch({super.key});

  @override
  State<PilotSearch> createState() => _PilotSearchState();
}

class _PilotSearchState extends State<PilotSearch> {
  TextEditingController _searchController = TextEditingController();
  List searchProducts = [];
  bool _searchInProgress = false;
  Future<void> search(String value) async {
    searchProducts.clear();
    _searchInProgress = true;
    if (mounted) {
      setState(() {});
    }
    Response response = await get(
      Uri.parse(
          'https://pilotbazar.com/api/merchants/vehicles/products/search?search=$value'),
      headers: {
        'Accept': 'application/vnd.api+json',
        'Content-Type': 'application/vnd.api+json'
      },
    );
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    int i = 0;

    for (i; i < decodedResponse['payload'].length; i++) {
      searchProducts.add(Product(
        vehicleName: decodedResponse['payload'][i]['slug'],
        id: decodedResponse['payload'][i]['id'],
      ));
    }
    _searchInProgress = false;
    if (mounted) {
      setState(() {});
    }
    if (decodedResponse['data'] == null) {
      return;
    }
  }

  List products = [];
  Future getData() async {
    Response response = await get(
      Uri.parse('https://pilotbazar.com/api/vehicle?page=1'),
    );
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    int i = 0;

    for (i; i < decodedResponse['data'].length; i++) {
      products.add(Product(
        vehicleName: decodedResponse['data'][i]['slug'],
        id: decodedResponse['data'][i]['id'],
      ));
    }

    if (mounted) {
      setState(() {});
    }
    if (decodedResponse['data'] == null) {
      return;
    }
  }

  void initState() {
    super.initState();
    getData();

    _searchController.addListener(() {
      // Clear the searchProducts list when the text field is empty
      if (_searchController.text.isEmpty) {
        searchProducts.clear();
        setState(() {});
      }
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: TextField(
        controller: _searchController,
        onSubmitted: (value) async {
          await search(value);
        },
      ),
    ),
    body: ListView.builder(
      itemCount: _searchInProgress ? 1 : (searchProducts.isNotEmpty ? searchProducts.length : products.length),
      itemBuilder: (context, index) {
        if (_searchInProgress) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (searchProducts.isNotEmpty) {
          return ListTile(
            title: Text(searchProducts[index].vehicleName),
          );
        } else {
          return ListTile(
            title: Text(products[index].vehicleName),
          );
        }
      },
    ),
  );
}

}
