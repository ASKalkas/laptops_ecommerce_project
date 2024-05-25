import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './Providers/productsProvider.dart';
import './Providers/authProvider.dart' as AuthProvider;
import './navBar.dart';
import './models/comment.dart';
import './Components/commentTile.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String _title = "Product";
  List<Comment> comments = [];

  String getStorage(double storage) {
    switch (storage) {
      case >= 4000:
        return "4 TB";
      case >= 3000:
        return "3 TB";
      case >= 2000:
        return "2 TB";
      case >= 1000:
        return "1 TB";
      case >= 512:
        return "512 GB";
      case >= 256:
        return "256 GB";
      case >= 128:
        return "128 GB";
      default:
        return "64 GB";
    }
  }

  Future<void> addComment(String? userID, String productID) async {
    final productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final TextEditingController contentController = TextEditingController();
    int rating = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add Comment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your comment...',
                    border:
                        OutlineInputBorder(), // Optional: Adds a border around the TextField
                  ),
                  minLines: 1, // Initial height
                  maxLines: 3, // Expands as the user types
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                          print(rating);
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () async {
                  String content = contentController.text;
                  String res = await productProvider.addComment(
                      content, rating, userID, productID);
                  String snackText = "Comment Created Successfully";
                  if (res == "error") {
                    snackText = 'Something Went Wrong';
                  }
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(snackText),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final productProvider =
        Provider.of<ProductsProvider>(context, listen: true);
    final authProvider =
        Provider.of<AuthProvider.AuthenticationProvider>(context, listen: true);

    _title = args["title"];
    comments = productProvider.comments;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.2, // Adjusted height for better text fitting
              ),
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
                )),
          ]),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: productProvider.getProduct(args["product"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AlertDialog(
                title: const Text('Something Went Wrong'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/home");
                    },
                    child: const Text('Back to Home'),
                  ),
                ]);
          } else {
            var product = snapshot.data!;
            return Column(
              children: [
                SizedBox(
                  width: screenWidth,
                  height: (220 / 640) * screenHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        left: (20 / 360) * screenWidth,
                        top: (15 / 640) * screenHeight,
                        child: Container(
                          width: (120 / 360) * screenWidth,
                          height: (80 / 640) * screenHeight,
                          decoration: BoxDecoration(
                            image: product["Image"] == null
                                ? DecorationImage(
                                    image: AssetImage(
                                        product["brand"] == "microsoft"
                                            ? "assets/Microsoft.png"
                                            : product["brand"] == "lenovo"
                                                ? "assets/Lenovo.png"
                                                : "assets/Asus.png"),
                                    // image: AssetImage("assets/Asus.png"),
                                    fit: BoxFit.fill,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(product["Image"]!),
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (150 / 360) * screenWidth,
                        top: (15 / 640) * screenHeight,
                        child: Text(
                          'Price: ${(product["price"] * 100).round() / 100} USD ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0,
                            decoration: product["hasDiscount"]
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      product["hasDiscount"]
                          ? Positioned(
                              left: (280 / 360) * screenWidth,
                              top: (15 / 640) * screenHeight,
                              child: const Icon(Icons.discount),
                            )
                          : const SizedBox(),
                      product["vendorID"].id == authProvider.userId
                          ? Positioned(
                              left: (320 / 360) * screenWidth,
                              top: 0,
                              child: IconButton(
                                onPressed: () {
                                  if (product["hasDiscount"]) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Are you sure?'),
                                          content: const Text(
                                              'Do you really want to remove Discount?'),
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
                                                Navigator.of(context)
                                                    .pop(); // Dismiss the dialog

                                                String res = await productProvider
                                                    .removeDiscount(product[
                                                        "productID"]); // Call the function to perform the action

                                                if (res == "error") {
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Something Went Wrong'),
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        TextEditingController controller =
                                            TextEditingController();
                                        return AlertDialog(
                                          title: const Text('Enter Discount'),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                hintText:
                                                    "Enter discount value"),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Submit'),
                                              onPressed: () async {
                                                String discountValue =
                                                    controller.text;
                                                if (discountValue.isNotEmpty) {
                                                  int discount =
                                                      int.parse(discountValue);
                                                  if (discount >= 0 &&
                                                      discount <= 100) {
                                                    String res =
                                                        await productProvider
                                                            .addDiscount(
                                                                discount,
                                                                product[
                                                                    "productID"]);
                                                    if (res == "error") {
                                                      // ignore: use_build_context_synchronously
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Something Went Wrong'),
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    }
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.of(context).pop();
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Please enter a value between 0 and 100')),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                icon: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.local_offer,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Icon(
                                          product["hasDiscount"]
                                              ? Icons.remove
                                              : Icons.add,
                                          color: Colors.black,
                                          size: 12),
                                    ),
                                  ],
                                ),
                              ))
                          : const SizedBox(),
                      authProvider.role?.toLowerCase() == 'vendor'
                          ? const SizedBox()
                          : Positioned(
                              left: (320 / 360) * screenWidth,
                              top: 0,
                              child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return authProvider.isAuthenticated
                                            ? AlertDialog(
                                                title:
                                                    const Text('Are you sure?'),
                                                content:
                                                    const Text('Add to Cart?'),
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
                                                      String res = await productProvider
                                                          .addToCart(
                                                              authProvider
                                                                  .userId,
                                                              product[
                                                                  "productID"]);
                                                      String snackText = "";
                                                      if (res == "error") {
                                                        snackText =
                                                            'Something Went Wrong';
                                                      } else if (res ==
                                                          "present") {
                                                        snackText =
                                                            'Product Already in Cart';
                                                      } else {
                                                        snackText =
                                                            'Product Added Successfully';
                                                      }
                                                      // ignore: use_build_context_synchronously
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content:
                                                              Text(snackText),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 3),
                                                        ),
                                                      );
                                                      // ignore: use_build_context_synchronously
                                                      Navigator.of(context)
                                                          .pop(); // Dismiss the dialog
                                                    },
                                                  ),
                                                ],
                                              )
                                            : AlertDialog(
                                                title: const Text(
                                                    'go to Login Page'),
                                                content: const Text(
                                                    'Must be Logged in to access cart'),
                                                actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                            context, "/login");
                                                      },
                                                      child: const Text(
                                                          'Go to Login/SignUp'),
                                                    ),
                                                  ]);
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.add_shopping_cart))),
                      product["hasDiscount"]
                          ? Positioned(
                              left: (150 / 360) * screenWidth,
                              top: (35 / 640) * screenHeight,
                              child: Text(
                                'Offer: ${((product["price"] * ((100 - product["discountAmount"]) / 100)) * 100).round() / 100} USD ',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            )
                          : const SizedBox(),
                      Positioned(
                        left: (150 / 360) * screenWidth,
                        top: (55 / 640) * screenHeight,
                        child: Text(
                          'Brand: ${product["brand"].toString().substring(0, 1).toUpperCase()}${product["brand"].toString().substring(1)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                      Positioned(
                        left: (10 / 360) * screenWidth,
                        top: (105 / 640) * screenHeight,
                        child: Container(
                            width: (340 / 360) * screenWidth,
                            height: (110 / 640) * screenHeight,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFD9D9D9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: (10 / 640) * screenHeight),
                                const Text(
                                  'Description:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height:
                                        1.2, // Adjusted height for better text fitting
                                  ),
                                ),
                                SizedBox(height: (5 / 640) * screenHeight),
                                SizedBox(
                                  width: (300 / 360) * screenWidth,
                                  child: Text(
                                    '${product["description"]}',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height:
                                          1.2, // Adjusted height for better text fitting
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (5 / 640) * screenHeight),
                SizedBox(
                  width: 0.95 * screenWidth,
                  height: (100 / 640) * screenHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 0.95 * screenWidth,
                          height: (90 / 640) * screenHeight,
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
                          left: 0,
                          top: (5 / 640) * screenHeight,
                          child: SizedBox(
                            width: 0.95 * screenWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Specs: ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                                SizedBox(height: (5 / 640) * screenHeight),
                                Text(
                                  'Processor: ${product["cpu"].toString().toUpperCase()}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                                SizedBox(height: (5 / 640) * screenHeight),
                                Text(
                                  'RAM: ${product["ram"]} GB',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                                SizedBox(height: (5 / 640) * screenHeight),
                                Text(
                                  'Storage: ${getStorage(product["storage"] + 0.0)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                                SizedBox(height: (5 / 640) * screenHeight),
                                Text(
                                  'GPU: ${product["gpu"].toString().toUpperCase()}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: (10 / 640) * screenHeight),
                product["rating"] > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return buildStar(context, index, product["rating"]);
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
                SizedBox(
                  height: (10 / 640) * screenHeight,
                ),
                SizedBox(
                  width: (340 / 360) * screenWidth,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Text(
                          'Comments:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height:
                                1.2, // Adjusted height for better text fitting
                          ),
                        ),
                      ),
                      authProvider.role?.toLowerCase() == "buyer"
                          ? SizedBox(
                              height: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_comment,
                                  size: 20,
                                ),
                                onPressed: () {
                                  addComment(authProvider.userId,
                                      product['productID']);
                                },
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                SizedBox(
                  height: (10 / 640) * screenHeight,
                ),
                Expanded(
                  child: comments.isEmpty
                      ? const Center(child: Text("No Comments Yet"))
                      : RefreshIndicator(
                          onRefresh: () async {
                            productProvider.fetchComments(product["productID"]);
                          },
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              Comment comment = comments[index];
                              return Column(children: [
                                CommentTile(
                                  comment: comment,
                                ),
                                SizedBox(height: (10 / 640) * screenHeight)
                              ]);
                            },
                          ),
                        ),
                )
              ],
            );
          }
        },
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget buildStar(BuildContext context, int index, rating) {
    IconData icon;
    if (index >= rating) {
      icon = Icons.star_border;
    } else if (index > rating - 1 && index < rating) {
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
