import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'details.dart';
import 'model.dart';

class ProductList extends StatefulWidget {
  final List<Product> products;

  ProductList({required this.products});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isSearching = false;
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    try {
      final fetchedProducts = await ApiService.fetchProducts();
      setState(() {
        products = fetchedProducts;
        filteredProducts = products;
      });
    } catch (a) {

    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else{
        filteredProducts = products
            .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: isSearching
            ? TextField(
          controller: search,
          onChanged: (query) {
            _filterProducts(query);
          },
          decoration: InputDecoration(
            hintText: 'Search Products',
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        )
            : Text(
          'Products',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: isSearching ? Icon(Icons.cancel) : Icon(Icons.search),
            onPressed: () {

              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  search.clear();
                  _filterProducts('');
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return ListTile(
              leading: CachedNetworkImage(
                imageUrl: product.thumbnail,
                placeholder: (context, url) =>
                    CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              title: Text(product.title),
              subtitle: Text('${product.price.toStringAsFixed(2)} USD'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>Details(product: product),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}