import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog_app_lesson/data/google_sing_in.dart';
import 'package:flutter/material.dart';

import '../data/blog_database.dart';
import '../data/blog_post_model.dart';
import '../widgets/blog_post_item.dart';
import '../widgets/create_blog_post_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BlogDatabase _blogDatabase = BlogDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Firebase Blog App"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app_outlined),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<BlogPostModel>>(
        stream: _blogDatabase.readBlogPost(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final blogList = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: blogList.length,
              itemBuilder: (context, index) {
                String documentId = blogList[index].id;
                final blogData = blogList[index].data();
                return BlogPostItem(blogData: blogData, docId: documentId);
              },
            );
          } else if (snapshot.hasError) {
            return Text("Something Wrong!");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createBlogPostDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createBlogPostDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreateBlogPostDialog();
      },
    );
  }
}
