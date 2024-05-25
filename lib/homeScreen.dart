import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './Providers/authProvider.dart' as AuthProvider;
import './Providers/productsProvider.dart';
import './models/product.dart';
import './Components/productTile.dart';
import './Components/filterForm.dart';
import './navBar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Product> filtered = [];
  bool isFiltered = false;
  final TextEditingController _searchController = TextEditingController();

  void filter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return FilterForm(
          onApplyFilter: (filterCriteria) => {applyFilter(filterCriteria)},
        );
      },
    );
  }

  void search() {
    if (_searchController.text == "") {
      setState(() {
        isFiltered = false;
        filtered.clear();
      });
    } else {
      List<Product> tmp = products.where((product) {
        return product.description.contains(_searchController.text) ||
            product.title.contains(_searchController.text);
      }).toList();

      setState(() {
        filtered = tmp;
        isFiltered = true;
      });
    }
  }

  void applyFilter(Map<String, dynamic> filterCriteria) {
    if (filterCriteria.isEmpty) {
      setState(() {
        isFiltered = false;
        filtered.clear();
      });
    } else {
      List<Product> tmp = products.where((product) {
        bool matches = true;
        // Check if the product's brand is in the list of allowed brands
        if (filterCriteria!['brand'] != null &&
            filterCriteria['brand']!.isNotEmpty) {
          matches &= filterCriteria['brand']!.contains(product.brand.toLowerCase());
        }

        // Check if the product's CPU is in the list of allowed CPUs
        if (filterCriteria['cpu'] != null &&
            filterCriteria['cpu']!.isNotEmpty) {
          matches &= filterCriteria['cpu']!.contains(product.cpu.toLowerCase());
        }

        // Check if the product's GPU is in the list of allowed GPUs
        if (filterCriteria['gpu'] != null &&
            filterCriteria['gpu']!.isNotEmpty) {
          matches &= filterCriteria['gpu']!.contains(product.gpu.toLowerCase());
        }

        // Check if the product's RAM is within the specified range
        if (filterCriteria['ram'] != null) {
          RangeValues ramRange = filterCriteria['ram'];
          matches &=
              product.ram >= ramRange.start && product.ram <= ramRange.end;
        }

        // Check if the product's storage is within the specified range
        if (filterCriteria['storage'] != null) {
          RangeValues storageRange = filterCriteria['storage'];
          matches &= product.storage >= storageRange.start &&
              product.storage <= storageRange.end;
        }

        // Check if the product's price is within the specified range
        if (filterCriteria['price'] != null) {
          RangeValues priceRange = filterCriteria['price'];
          matches &= product.price >= priceRange.start &&
              product.price <= priceRange.end;
        }
        return matches;
      }).toList();

      setState(() {
        isFiltered = true;
        filtered = tmp;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch products when the widget is first created
    Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    final authProvider = Provider.of<AuthProvider.AuthenticationProvider>(
        context,
        listen: false);
    final productProvider =
        Provider.of<ProductsProvider>(context, listen: true);
    products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'HOME',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(1.00, 0.00),
              end: Alignment(-1, 0),
              colors: [Colors.white, Color.fromARGB(255, 48, 46, 46)],
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                authProvider.signOut();
                authProvider.setUserID(null);
                Navigator.pushNamed(context, "/login");
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: (12 / 640) * screenHeight,
          ),
          SizedBox(
            width: (353 / 360) * screenWidth,
            height: (21 / 640) * screenHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 1,
                  top: 0,
                  child: Container(
                    width: (352 / 360) * screenWidth,
                    height: (20 / 640) * screenHeight,
                    decoration: ShapeDecoration(
                      color: const Color.fromARGB(255, 58, 56, 56)
                          .withOpacity(0.3700000047683716),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(84),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (30 / 360) * screenWidth,
                  top: (3 / 640) * screenHeight,
                  child: SizedBox(
                    width: (200 / 360) * screenWidth,
                    height: (42 / 640) * screenHeight,
                    child: TextField(
                      controller: _searchController,
                      showCursor: true,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        hintText: 'Search', // Placeholder text
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 30),
                      ),
                      onChanged: (value) {
                        search();
                      },
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (5 / 360) * screenWidth,
                  top: 0,
                  child: Container(
                    width: (21 / 360) * screenWidth,
                    height: (21 / 360) * screenWidth,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: const Icon(Icons.search),
                  ),
                ),
                Positioned(
                  left: (325 / 360) * screenWidth,
                  top: 0,
                  child: Container(
                      width: (21 / 360) * screenWidth,
                      height: (21 / 360) * screenWidth,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        onPressed: () => {filter()},
                        child: const Icon(
                          Icons.filter_alt,
                          color: Colors.black,
                        ),
                      )),
                ),
              ],
            ),
          ),
          SizedBox(
            height: (12 / 640) * screenHeight,
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text("There are no Products yet!"))
                : RefreshIndicator(
                    onRefresh: productProvider.fetchProducts,
                    child: ListView.builder(
                      itemCount: isFiltered ? filtered.length : products.length,
                      itemBuilder: (context, index) {
                        Product product =
                            isFiltered ? filtered[index] : products[index];
                        return Column(children: [
                          ProductTile(
                            product: product,
                            inCart: false,
                          ),
                          SizedBox(height: (10 / 640) * screenHeight)
                        ]);
                      },
                    ),
                  ),
          )
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
