import 'package:firebase_blog_app_lesson/data/blog_database.dart';
import 'package:flutter/material.dart';

import '../data/blog_post_model.dart';
import 'edit_blog_post_dialog.dart';

class BlogPostItem extends StatefulWidget {
  const new({super.key, required this.blogData, required this.docId});

  final BlogPostModel blogData;
  final String docId;

  @override
  State<BlogPostItem> createState() => _BlogPostItemState();
}

class _BlogPostItemState extends State<BlogPostItem> {
  final MenuController _menuController = MenuController();
  final BlogDatabase _blogDatabase = BlogDatabase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "Maung Maung",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  MenuAnchor(
                    controller: _menuController,
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          _menuController.close();
                          _updateBlogPost(
                            blogPostModel: widget.blogData,
                            docId: widget.docId,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("Edit"),
                        ),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          _menuController.close();
                          _deleteBlogPost(widget.docId);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("Delete"),
                        ),
                      ),
                    ],
                    builder: (_, _, _) {
                      return IconButton(
                        onPressed: () {
                          _menuController.open();
                        },
                        icon: Icon(Icons.more_vert),
                      );
                    },
                  ),
                ],
              ),
              Center(
                child: Text(
                  widget.blogData.title ?? "",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 4),
              Text(widget.blogData.description ?? ""),
              SizedBox(height: 4),
              if(widget.blogData.image != null)
              Image.memory(widget.blogData.image!.bytes)
            ],
          ),
        ),
      ),
    );
  }

  void _updateBlogPost({
    required BlogPostModel blogPostModel,
    required String docId,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return EditBlogPostDialog(blogPostModel: blogPostModel, docId: docId);
      },
    );
  }

  void _deleteBlogPost(String docId) async {
    try {
      await _blogDatabase.deleteBlogPost(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Delete Blog Post Sucessfully",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Delete Blog Post Failed $e",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }
}
