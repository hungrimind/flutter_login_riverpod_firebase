import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_provider.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<UserState?> currentUser = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Starter App"),
      ),
      body: currentUser.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text("No user found"));
          }
          return Center(
            child: Column(
              children: [
                Text(data.user.email),
                if (data.user.username != null) Text(data.user.username!),
                Text(data.user.dateCreated.toString()),
                Container(
                  padding: const EdgeInsets.all(8),
                  width: 400,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Update username",
                    ),
                    onChanged: (value) {
                      ref
                          .read(userProvider.notifier)
                          .updateUsername(data.id, value);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          return Center(child: Text(error.toString()));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ref.watch(userProvider.notifier).logout();
        },
        label: const Text("Sign Out"),
      ),
    );
  }
}
