import 'package:flutter/material.dart';

import '../data/blog_database.dart';
import '../data/blog_post_model.dart';

class UpdateBlogPostDialog extends StatefulWidget {
  const UpdateBlogPostDialog({
    super.key,
    required this.blogPostModel,
    required this.docId,
  });

  final BlogPostModel blogPostModel;
  final String docId;

  @override
  State<UpdateBlogPostDialog> createState() => _UpdateBlogPostDialogState();
}

class _UpdateBlogPostDialogState extends State<UpdateBlogPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BlogDatabase _blogDatabase = BlogDatabase();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.blogPostModel.title ?? "";
    _descriptionController.text = widget.blogPostModel.description ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Update Blog Post",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _titleController,
            minLines: 1,
            maxLines: 2,
            decoration: InputDecoration(
              hint: Text("Title ..."),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 4),
          TextField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hint: Text("Description"),
              border: OutlineInputBorder(),
            ),
          ),
          if (_isLoading == true) SizedBox(height: 8),
          if (_isLoading == true) CircularProgressIndicator(),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty ||
                    _descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.orange,
                      content: Text("Please Fill Title and Description"),
                    ),
                  );
                } else {
                  _isLoading = true;
                  try {
                    await _blogDatabase.updateBlogPost(
                      blogPostModel: BlogPostModel(
                        title: _titleController.text,
                        description: _descriptionController.text,
                      ),
                      docId: widget.docId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            "Update Blog Post Sucessfully",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Update Blog Post Failed!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  } finally {
                    _isLoading = false;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                }
              },
              child: Text("Update Blog Post"),
            ),
          ],
        ),
      ],
    );
  }
}
