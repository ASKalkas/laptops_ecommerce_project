const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./key.json");

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
});

exports.notifyNewProduct = functions.firestore
	.document("Products/{productId}")
	.onCreate(async (snap, context) => {
		const newValue = snap.data();
		const payload = {
			notification: {
				title: "New Product Added",
				body: `Check out the new product: ${newValue.title}`,
			},
		};

		// Fetch the FCM tokens of the specific type of users
		const userType = "Buyer"; // Replace with your user type
		const tokensSnapshot = await admin
			.firestore()
			.collection("Users")
			.where("role", "==", userType)
			.where("fcmToken", "!=", null)
			.get();

		const tokens = tokensSnapshot.docs.map((doc) => doc.data().fcmToken);

		if (tokens.length > 0) {
			try {
				console.log(tokens[0]);
				await admin.messaging().sendEachForMulticast({
					tokens: tokens,
					notification: payload.notification,
				});
				console.log("Notification sent successfully");
			} catch (error) {
				console.error("Error sending notification:", error);
			}
		} else {
			console.log("No tokens found for the specified user type");
		}
	});

exports.notifyVendorOnComment = functions.firestore
	.document("Comments/{commentId}")
	.onCreate(async (snap, context) => {
		const commentData = snap.data();
		const productId = commentData.productID; // Assuming the comment document has a field 'productId'

		// Fetch the product to get the vendor ID
		const productSnapshot = await admin
			.firestore()
			.collection("Products")
			.doc(productId)
			.get();
		const productData = productSnapshot.data();
		const vendorRef = productData.vendorID;

		// Fetch the vendor's FCM token
		// Fetch the vendor's FCM token
		const vendorSnapshot = await vendorRef.get();
		const vendorData = vendorSnapshot.data();
		const vendorToken = vendorData.fcmToken;

		if (vendorToken) {
			const payload = {
				notification: {
					title: "New Comment on Your Product",
					body: `Someone commented: ${commentData.rating} Star Rating`,
				},
			};

			try {
				await admin.messaging().send({
					token: vendorToken,
					notification: payload.notification,
				});
				console.log("Notification sent to vendor successfully");
			} catch (error) {
				console.error("Error sending notification to vendor:", error);
			}
		} else {
			console.log("No FCM token found for the vendor");
		}
	});

exports.notifyBuyersOnDiscount = functions.firestore
	.document("Products/{productId}")
	.onUpdate(async (change, context) => {
		const newValue = change.after.data();
		const previousValue = change.before.data();

		// Check if the hasDiscount field changed to true
		if (newValue.hasDiscount && !previousValue.hasDiscount) {
			const payload = {
				notification: {
					title: "Discount Alert!",
					body: `The product ${newValue.title} is now on a ${newValue.discountAmount}% discount!`,
				},
			};

			// Fetch all buyers' FCM tokens
			const userType = "Buyer"; // Replace with your user type
			const tokensSnapshot = await admin
				.firestore()
				.collection("Users")
				.where("role", "==", userType)
				.where("fcmToken", "!=", null)
				.get();

			const tokens = tokensSnapshot.docs.map((doc) => doc.data().fcmToken);

			if (tokens.length > 0) {
				try {
					console.log(tokens[0]);
					await admin.messaging().sendEachForMulticast({
						tokens: tokens,
						notification: payload.notification,
					});
					console.log("Notification sent successfully");
				} catch (error) {
					console.error("Error sending notification:", error);
				}
			} else {
				console.log("No tokens found for the specified user type");
			}
		}
	});
