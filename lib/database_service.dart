import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final DatabaseReference _firebaseDatabase = FirebaseDatabase.instance.ref();
  DatabaseReference get firebaseDatabase => _firebaseDatabase;

  get db => null;

  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.child(path);
    await ref.set(data);
  }

  Future<DataSnapshot?> read({
    required String path,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.child(path);
    final DataSnapshot snapshot = await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref.child(path);
    await ref.update(data);
  }

  Future<void> delete({required String path}) async {
    final DatabaseReference ref = _firebaseDatabase.ref.child(path);
    await ref.remove();
  }

 Future<void> registerUser(
  String username,
  String email,
  String contactNumber,
  String password,
) async {
  final int newId = await generateCustomerId();

  final String path = 'Customer/$newId';

  final Map<String, dynamic> data = {
    'customer_id': newId,
    'customer_username': username,
    'customer_email': email,
    'customer_contactNumber': contactNumber,
    'customer_password': password,
    'customer_Fname': 'Customer',
    'customer_Lname': newId.toString(),
  };

  await create(path: path, data: data);
}

  Future<int> generateCustomerId() async {
  final ref = FirebaseDatabase.instance.ref("Customer");
  final snapshot = await ref.get();

  if (!snapshot.exists) return 1;

  List<int> existingIds = [];

  for (var child in snapshot.children) {
    final id = int.tryParse(child.key ?? "");
    if (id != null) {
      existingIds.add(id);
    }
  }

  int nextId = 1;
  while (existingIds.contains(nextId)) {
    nextId++;
  }

  return nextId;
}



  Future<bool> addProductStock({
    required String productId,
    required String productName,
    required String productCategory,
    required String flavor,
    required int quantityToAdd,
  }) async {
    final path = 'Product/$productId';
    final snapshot = await _firebaseDatabase.child(path).get();

    if (!snapshot.exists) {
      return false;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;

    if (data['product_name'] != productName ||
        data['product_category'] != productCategory ||
        data['flavor'] != flavor) {
      return false; 
    }

    int currentStock = int.tryParse(data['inStock'].toString()) ?? 0;
    int newStock = currentStock + quantityToAdd;

    await _firebaseDatabase.child(path).update({'inStock': newStock});

    return true;
  }

  Future<void> addIngredient({
    required String ingredientId,
    required String ingredientName,
  }) async {
    final path = 'Ingredients/$ingredientId';
    final snapshot = await _firebaseDatabase.child(path).get();

    if (snapshot.exists) {
      throw Exception('Ingredient with ID $ingredientId already exists.');
    }

    await _firebaseDatabase.child(path).set({
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'quantity': 0,
    });
  }

  Future<bool> addIngredientStock({
    required String ingredientId,
    required String ingredientName,
    required int quantityToAdd,
  }) async {
    final path = 'Ingredients/$ingredientId';
    final snapshot = await _firebaseDatabase.child(path).get();

    if (!snapshot.exists) {
      return false; 
    }

    final data = snapshot.value as Map<dynamic, dynamic>;

    if (data['ingredient_name'] != ingredientName) {
      return false; 
    }

    int currentStock = int.tryParse(data['quantity'].toString()) ?? 0;
    int newStock = currentStock + quantityToAdd;

    await _firebaseDatabase.child(path).update({'quantity': newStock});

    return true;
  }

  Future<Map<String, dynamic>?> validateStaffLogin({
  required String username,
  required String password,
}) async {
  final ref = FirebaseDatabase.instance.ref("Staff");
  final snapshot = await ref.get();

  if (!snapshot.exists) return null;

  for (var child in snapshot.children) {
    final data = child.value as Map<dynamic, dynamic>;
    final dbUsername = data['staff_username']?.toString() ?? '';
    final dbPassword = data['staff_password']?.toString() ?? '';

    if (dbUsername == username && dbPassword == password) {
      return Map<String, dynamic>.from(data);
    }
  }

  return null;
}

Future<bool> validateCustomerLogin({
  required String username,
  required String password,
}) async {
  try {
    final snapshot = await _firebaseDatabase.child('Customer').get();

    if (!snapshot.exists || snapshot.value == null) {
      return false;
    }

    final data = snapshot.value;

    if (data is List) {
      for (var entry in data) {
        if (entry == null) continue; 

        final user = Map<String, dynamic>.from(entry);

        if (user['customer_email'] == username &&
            user['customer_password'] == password) {
          return true;
        }
      }
      return false;
    }

    if (data is Map) {
      for (var entry in data.values) {
        final user = Map<String, dynamic>.from(entry);

        if (user['customer_email'] == username &&
            user['customer_password'] == password) {
          return true;
        }
      }
      return false;
    }

    return false;
  } catch (e) {
    print("Login error: $e");
    return false;
  }
}

Future<Map<String, dynamic>?> getCustomerByLogin({
  required String username,
  required String password,
}) async {
  final snapshot = await _firebaseDatabase
      .child('Customer')
      .orderByChild('customer_email')
      .equalTo(username)
      .get();

  if (snapshot.exists) {
    final customers = snapshot.value as Map<dynamic, dynamic>;
    for (var customer in customers.values) {
      if (customer['customer_password'] == password) {
        return Map<String, dynamic>.from(customer); 
      }
    }
  }
  return null;
}


 Future<String> uploadProductImage(String productId, Uint8List imageBytes) async {
    final storageRef = FirebaseStorage.instance.ref('products/$productId.png');
    await storageRef.putData(imageBytes);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  

}
