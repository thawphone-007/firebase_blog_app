import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/blog_database.dart';
import '../data/blog_post_model.dart';

class CreateBlogPostDialog extends StatefulWidget {
  const CreateBlogPostDialog({super.key});

  @override
  State<CreateBlogPostDialog> createState() => _CreateBlogPostDialogState();
}

class _CreateBlogPostDialogState extends State<CreateBlogPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BlogDatabase _blogDatabase = BlogDatabase();
  bool _isLoading = false;
  Uint8List? _image;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Create Blog Post",
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
          SizedBox(height: 4),
          if (_image == null)
            IconButton(
              onPressed: () async {
                XFile? image = await _pickImage();
                if (image != null) {
                  _image = await image.readAsBytes();
                  setState(() {});
                }
              },
              icon: Icon(Icons.image, size: 40, color: Colors.lightBlueAccent),
            ),
          if (_image != null)
            Image.memory(_image!, width: 200, height: 150, fit: BoxFit.cover),
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
              onPressed: _isLoading == true
                  ? null
                  : () async {
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
                          await _blogDatabase.createBlogPost(
                            blogPostModel: BlogPostModel(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              image: _image != null ? Blob(_image!) : null,
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  "Create Blog Post Sucessfully",
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
                                  "Create Blog Post Failed!",
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
              child: Text("Create Blog Post"),
            ),
          ],
        ),
      ],
    );
  }

  Future<XFile?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }
}
