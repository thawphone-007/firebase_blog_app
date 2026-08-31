import 'package:flutter/material.dart';

import '../data/blog_database.dart';
import '../data/blog_post_model.dart';
import 'update_blog_post_dialog.dart';

class BlogPostItem extends StatefulWidget {
  const new({super.key, required this.blogData, required this.docId});

  final BlogPostModel blogData;
  final String docId;

  @override
  State<BlogPostItem> createState() => _BlogPostItemState();
}

class _BlogPostItemState extends State<BlogPostItem> {
  final BlogDatabase _blogDatabase = BlogDatabase();
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.lightBlueAccent,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  MenuAnchor(
                    controller: _menuController,
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          _menuController.close();
                          _updateBlogPostDialog(
                            blogPostModel: widget.blogData,
                            docId: widget.docId,
                          );
                        },
                        child: Text("Edit"),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          _menuController.close();
                          _deleteBlogPost(widget.docId);
                        },
                        child: Text("Delete"),
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
              Divider(),
              Center(
                child: Text(
                  widget.blogData.title ?? "",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 4),
              Text(widget.blogData.description ?? ""),
              if (widget.blogData.image != null)
                Image.memory(widget.blogData.image!.bytes),
            ],
          ),
        ),
      ),
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
              "Delete Blog Post Failed!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _updateBlogPostDialog({
    required BlogPostModel blogPostModel,
    required String docId,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return UpdateBlogPostDialog(blogPostModel: blogPostModel, docId: docId);
      },
    );
  }
}
