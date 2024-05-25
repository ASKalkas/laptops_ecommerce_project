import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './Providers/authProvider.dart' as AuthProvider;
import './Providers/productsProvider.dart';
import './models/product.dart';
import './Components/productTile.dart';
import './navBar.dart';

class CartStock extends StatefulWidget {
  const CartStock({super.key});

  @override
  State<CartStock> createState() => _CartStockState();
}

class _CartStockState extends State<CartStock> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    // Fetch products when the widget is first created
    final authProvider = Provider.of<AuthProvider.AuthenticationProvider>(
        context,
        listen: false);
    // print("ID ${authProvider.userId}");
    Provider.of<ProductsProvider>(context, listen: false)
        .fetchCartStock(authProvider.userId);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
        title: Text(
          authProvider.role?.toLowerCase() == "vendor" ? "Stock" : "Cart",
          style: const TextStyle(
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
          authProvider.role?.toLowerCase() == "vendor"
              ? IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/addItem");
                  },
                  icon: const Icon(
                    Icons.add_circle_outlined,
                    color: Colors.black,
                  ))
              : const SizedBox(),
          IconButton(
              onPressed: () async {
                authProvider.signOut();
                authProvider.setUserID(null);
                Navigator.pushNamed(context, "/login");
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              )),
        ],
      ),
      body: authProvider.isAuthenticated
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: (12 / 640) * screenHeight,
                ),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Text(
                              authProvider.role?.toLowerCase() == 'vendor'
                                  ? "You Have no Items in Store"
                                  : "You Have no Items in Cart"))
                      : RefreshIndicator(
                          onRefresh: () async {
                            await productProvider
                                .fetchCartStock(authProvider.userId);
                          },
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              Product product = products[index];
                              return Column(children: [
                                ProductTile(
                                  product: product,
                                  inCart: true,
                                ),
                                SizedBox(height: (10 / 640) * screenHeight)
                              ]);
                            },
                          ),
                        ),
                )
              ],
            )
          : AlertDialog(
              title: const Text('go to Login Page'),
              content: const Text('Must be Logged in to access cart'),
              actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    child: const Text('Go to Login/SignUp'),
                  ),
                ]),
      bottomNavigationBar: const NavBar(),
    );
  }
}
