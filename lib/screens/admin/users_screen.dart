import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Interests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return const Center(child: Text('Something went wrong fetching users'));
          }

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = userSnapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text('No users found in the database.'),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final username = user['username'] ?? 'N/A';
              final mobileNumber = user['mobileNumber'] ?? user['mobile'] ?? 'N/A';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('property_preferences')
                    .doc(userId)
                    .get(),
                builder: (context, prefSnapshot) {
                  Widget interestWidget;

                  if (prefSnapshot.connectionState == ConnectionState.waiting) {
                    interestWidget = const Text('Status: Loading...');
                  } else if (prefSnapshot.hasError) {
                    interestWidget = const Text('Status: Error', style: TextStyle(color: Colors.red));
                  } else if (prefSnapshot.hasData && prefSnapshot.data!.exists) {
                    final prefData = prefSnapshot.data!.data() as Map<String, dynamic>;

                    // More robust check for true interests
                    const interestKeys = [
                      'flat',
                      'house_for_rent',
                      'house_for_sale',
                      'land_for_rent',
                      'land_for_sale',
                      'shop_for_rent',
                      'shop_for_sale'
                    ];
                    
                    final trueInterests = interestKeys
                        .where((key) => prefData.containsKey(key) && prefData[key] == true)
                        .map((key) => key.replaceAll('_', ' ').replaceFirst(key[0], key[0].toUpperCase()))
                        .toList();

                    if (trueInterests.isNotEmpty) {
                       interestWidget = Text(
                        trueInterests.join(', '),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                      );
                    } else {
                      interestWidget = const Text(
                        'Not actively looking',
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      );
                    }
                  } else {
                    interestWidget = const Text(
                      'Property preference not set',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username: $username',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8.0),
                          Text('Mobile Number: $mobileNumber'),
                          const SizedBox(height: 12.0),
                          const Text(
                            'Interested In:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4.0),
                          interestWidget,
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
