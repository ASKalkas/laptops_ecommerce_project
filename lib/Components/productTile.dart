import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/productsProvider.dart';
import '../Providers/authProvider.dart' as AuthProvider;
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.inCart});

  final Product product;
  final bool inCart;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    final productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider.AuthenticationProvider>(
        context,
        listen: false);

    return GestureDetector(
      onTap: () async {
        await productProvider.fetchComments(product.productID);
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(
          context,
          "/product",
          arguments: {"product": product.productID, "title": product.title},
        );
      },
      child: SizedBox(
        width: (347 / 360) * screenWidth,
        height: (87 / 640) * screenHeight,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: (347 / 360) * screenWidth,
                height: (87 / 640) * screenHeight,
                decoration: ShapeDecoration(
                  color: const Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: (10 / 360) * screenWidth,
              top: (14 / 640) * screenHeight,
              child: Container(
                width: (90 / 360) * screenWidth,
                height: (61 / 640) * screenHeight,
                decoration: BoxDecoration(
                  image: product.image == null
                      ? DecorationImage(
                          image: AssetImage(product.brand == "microsoft"
                              ? "assets/Microsoft.png"
                              : product.brand == "lenovo"
                                  ? "assets/Lenovo.png"
                                  : "assets/Asus.png"),
                          // image: AssetImage("assets/Asus.png"),
                          fit: BoxFit.fill,
                        )
                      : DecorationImage(
                          image: NetworkImage(product.image!),
                          fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
                left: (110 / 360) * screenWidth,
                top: (19 / 640) * screenHeight,
                child: Row(
                  children: [
                    SizedBox(
                      width: (88 / 360) * screenWidth,
                      child: Text(
                        product.title,
                        maxLines: 1, // Limit to 1 line
                        overflow:
                            TextOverflow.ellipsis, // Truncate with ellipsis
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: (5 / 640) * screenHeight),
                    Text(
                      'Brand: ${product.brand}',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                )),
            inCart
                ? Positioned(
                    left: (300 / 360) * screenWidth,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Are you sure?'),
                                content: product.vendorID == authProvider.userId
                                    ? const Text('Remove From Stock?')
                                    : const Text('Remove From Cart?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('No'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Dismiss the dialog
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () async {
                                      String res = "";
                                      if (product.vendorID ==
                                          authProvider.userId) {
                                        res = await productProvider.deleteItem(
                                            product.productID,
                                            product.vendorID);
                                      } else {
                                        res = await productProvider
                                            .removeFromCart(authProvider.userId,
                                                product.productID);
                                      }
                                      String snackText = "";
                                      if (res == "error") {
                                        snackText = 'Something Went Wrong';
                                      } else if (res == "present") {
                                        snackText = 'Product Not in Cart';
                                      } else {
                                        snackText =
                                            'Product Removed Successfully';
                                      }
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(snackText),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context)
                                          .pop(); // Dismiss the dialog
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      icon: product.vendorID == authProvider.userId
                          ? const Icon(Icons.delete)
                          : const Icon(Icons.remove_shopping_cart_outlined),
                    ),
                  )
                : const SizedBox(),
            Positioned(
                left: (110 / 360) * screenWidth,
                top: (40 / 640) * screenHeight,
                child: Row(
                  children: [
                    Text(
                      '${product.price} USD',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                    product.hasDiscount
                        ? Icon(Icons.discount, size: (20 / 360) * screenWidth)
                        : const SizedBox(),
                  ],
                )),
            Positioned(
              left: (105 / 360) * screenWidth,
              top: (60 / 640) * screenHeight,
              child: product.rating > 0
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return buildStar(context, index);
                      }),
                    )
                  : const Text(
                      "Product Has no Ratings",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStar(BuildContext context, int index) {
    IconData icon;
    if (index >= product.rating) {
      icon = Icons.star_border;
    } else if (index > product.rating - 1 && index < product.rating) {
      icon = Icons.star_half;
    } else {
      icon = Icons.star;
    }
    return Icon(
      icon,
      color: Colors.amber,
    );
  }
}
