import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/blog_database.dart';
import '../data/blog_post_model.dart';
import '../widgets/add_blog_post_dialog.dart';
import '../widgets/blog_post_item.dart';

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
      appBar: AppBar(centerTitle: true, title: Text("Firebase Blog App")),

      body: StreamBuilder<QuerySnapshot<BlogPostModel>>(
        stream: _blogDatabase.readBlogList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot<BlogPostModel>> blogList =
                snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: blogList.length,
              itemBuilder: (context, index) {
                final BlogPostModel blogData = blogList[index].data();
                final String documentId = blogList[index].id;

                return BlogPostItem(blogData: blogData, docId: documentId,);
              },
            );
          } else if (snapshot.hasError) {
            return Text("Somethings Wrong");
          }
          return CircularProgressIndicator();
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addBlogPostDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addBlogPostDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddBlogPostDialog();
      },
    );
  }


}


