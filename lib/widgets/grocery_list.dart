import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/categories.dart';

import 'package:shop/models/grocery_item.dart';
import 'package:shop/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;
  void _loadData() async {
    final Uri url = Uri.https(
        'flutter-test-8a62b-default-rtdb.firebaseio.com', 'shopping-list.json');
    final http.Response res = await http.get(url).catchError((_) {
      return http.Response('', 400);
    });
    if (res.statusCode >= 400) {
      setState(() {
        _error = 'failed to fetch data';
      });
      return;
    }
    if (res.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> loadedData = json.decode(res.body);
    final List<GroceryItem> loadedItems = [];

    for (var item in loadedData.entries) {
      try {
        var category = categories.entries
            .firstWhere(
              (element) => element.value.title == item.value['category'],
            )
            .value;

        loadedItems.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category),
        );
        setState(() {
          _groceryItems = loadedItems;
          _isLoading = false;
        });
      } catch (e) {
        // Handle the case where no element is found
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Items added yet'),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (_) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(
              _groceryItems[index].name,
            ),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grocery'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final Uri url = Uri.https('flutter-test-8a62b-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      ScaffoldMessenger.of(context)
          .showSnackBar((const SnackBar(content: Text('failed to remove'))));
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(
      () {
        _groceryItems.add(newItem);
      },
    );
  }
}
