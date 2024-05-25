import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/comment.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Comment> _comments = [];

  List<Product> get products {
    return _products;
  }

  List<Comment> get comments {
    return _comments;
  }

  Future<void> fetchProducts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Products').get();
    _products = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Product(
        productID: doc.id,
        image: data.containsKey("Image") ? doc["Image"] : null,
        description: doc["description"],
        brand: doc['brand'],
        cpu: doc['cpu'],
        discountAmount: doc['hasDiscount'] ? doc['discountAmount'] : null,
        gpu: doc['gpu'],
        hasDiscount: doc['hasDiscount'],
        price: (doc['price'] * 100).round() / 100,
        ram: doc['ram'],
        storage: doc['storage'],
        title: doc['title'],
        rating: doc['rating'] + 0.0,
        vendorID: doc['vendorID'].id,
      );
    }).toList();

    notifyListeners();
  }

  Future<void> fetchCartStock(String? userID) async {
    _products.clear();
    if (userID != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userID)
          .get();

      List<dynamic> references;

      if (userDoc.get("role").toString().toLowerCase() == 'vendor') {
        references = userDoc.get('stock');
      } else {
        references = userDoc.get('cart');
      }

      for (DocumentReference productRef in references) {
        DocumentSnapshot productDoc = await productRef.get();
        _products.add(Product(
          productID: productDoc.id,
          image:
              (productDoc.data() as Map<String, dynamic>).containsKey("Image")
                  ? productDoc.get("Image")
                  : null,
          description: productDoc.get("description"),
          brand: productDoc.get('brand'),
          cpu: productDoc.get('cpu'),
          discountAmount: productDoc.get('hasDiscount')
              ? productDoc.get('discountAmount')
              : null,
          gpu: productDoc.get('gpu'),
          hasDiscount: productDoc.get('hasDiscount'),
          price: (productDoc.get('price') * 100).round() / 100,
          ram: productDoc.get('ram'),
          storage: productDoc.get('storage'),
          title: productDoc.get('title'),
          rating: productDoc.get('rating') + 0.0,
          vendorID: productDoc.get('vendorID').id,
        ));
      }
      notifyListeners();
    }
  }

  Future<String> addItem(Map<String, dynamic> doc) async {
    try {
      doc["vendorID"] =
          FirebaseFirestore.instance.collection('Users').doc(doc["vendorID"]);
      doc["hasDiscount"] = false;
      doc["rating"] = 0.0;

      if (doc["Image"] != null) {
        var imageName = DateTime.now().millisecondsSinceEpoch.toString();
        var storageRef = FirebaseStorage.instance
            .ref()
            .child('driver_images/$imageName.jpg');
        var uploadTask = storageRef.putFile(doc["Image"]);
        var downloadUrl = await (await uploadTask).ref.getDownloadURL();

        doc["Image"] = downloadUrl;
      }

      DocumentReference productRef =
          await FirebaseFirestore.instance.collection('Products').add(doc);
      await doc["vendorID"].update({
        "stock": FieldValue.arrayUnion([productRef])
      });
      notifyListeners();
      return "success";
    } catch (error) {
      return "failed";
    }
  }

  Future<Map<String, dynamic>?> getProduct(String? productID) async {
    DocumentSnapshot productDoc = await FirebaseFirestore.instance
        .collection('Products')
        .doc(productID)
        .get();

    Map<String, dynamic>? product = productDoc.data() as Map<String, dynamic>?;

    product?["productID"] = productDoc.id;
    return product;
  }

  Future<void> fetchComments(String? productID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Comments') // Replace 'Comments' with your collection name
        .where('productID', isEqualTo: productID)
        .get();

    _comments = querySnapshot.docs.map((doc) {
      return Comment(
          commentID: doc.id,
          productID: doc['productID'],
          rating: doc['rating'] + 0.0,
          buyerName: doc['buyerName'],
          content: doc['content']);
    }).toList();

    notifyListeners();
  }

  Future<String> addDiscount(int discount, String productID) async {
    try {
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('Products').doc(productID);

      // Retrieve the document snapshot
      DocumentSnapshot productDoc = await productRef.get();

      if (productDoc.exists) {
        // Update the document
        await productRef.update({
          'hasDiscount': true,
          'discountAmount': discount,
        });
        notifyListeners();
        return 'success';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future<String> removeDiscount(String productID) async {
    try {
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('Products').doc(productID);

      // Retrieve the document snapshot
      DocumentSnapshot productDoc = await productRef.get();

      if (productDoc.exists) {
        // Update the document
        await productRef.update({
          'hasDiscount': false,
        });
        notifyListeners();
        return 'success';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future<String> addToCart(String? userID, String productID) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userID);

      DocumentReference productRef =
          FirebaseFirestore.instance.collection('Products').doc(productID);

      // Retrieve the document snapshot
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        List<dynamic> arrayField = userDoc.get('cart');
        if (arrayField.contains(productRef)) {
          return 'present';
        }

        // Update the document
        await userRef.update({
          "cart": FieldValue.arrayUnion([productRef])
        });
        notifyListeners();
        return 'success';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future<String> removeFromCart(String? userID, String productID) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userID);

      DocumentReference productRef =
          FirebaseFirestore.instance.collection('Products').doc(productID);

      // Retrieve the document snapshot
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        List<dynamic> arrayField = userDoc.get('cart');
        if (!arrayField.contains(productRef)) {
          return 'present';
        }

        // Update the document
        await userRef.update({
          "cart": FieldValue.arrayRemove([productRef])
        });

        _products.removeWhere((product) => product.productID == productID);

        notifyListeners();
        return 'success';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future<String> addComment(
      String content, int rating, String? userID, String productID) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userID);

      DocumentSnapshot userDoc = await userRef.get();
      String username = userDoc.get("name");

      Map<String, dynamic> doc = {
        "buyerName": username,
        "content": content,
        "rating": rating,
        "productID": productID
      };

      DocumentReference ref =
          await FirebaseFirestore.instance.collection('Comments').add(doc);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(
              'Comments') // Replace 'Comments' with your collection name
          .where('productID', isEqualTo: productID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        int ratingCount = 0;

        for (var doc in querySnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('rating')) {
            totalRating += data['rating'];
            ratingCount++;
          }
        }

        DocumentReference productRef =
            FirebaseFirestore.instance.collection('Products').doc(productID);

        await productRef.update({"rating": totalRating / ratingCount});
      }

      _comments.add(Comment(
          buyerName: username,
          commentID: ref.id,
          content: content,
          productID: productID,
          rating: rating + 0.0));

      notifyListeners();
      return 'success';
    } catch (e) {
      print(e);
      return 'error';
    }
  }

  Future<String> deleteItem(String productID, String? userID) async {
    try {
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('Products').doc(productID);

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userID);

      // Delete the document
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        List<dynamic> arrayField = userDoc.get('stock');
        if (!arrayField.contains(productRef)) {
          return 'present';
        }

        // Update the document
        await userRef.update({
          "stock": FieldValue.arrayRemove([productRef])
        });
      }

      QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
          .collection('Comments')
          .where('productID', isEqualTo: productID)
          .get();

      for (QueryDocumentSnapshot doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }
      await productRef.delete();

      _products.removeWhere((product) => product.productID == productID);
      print(_products);
      notifyListeners();
      return 'success';
    } catch (e) {
      return 'error';
    }
  }
}
