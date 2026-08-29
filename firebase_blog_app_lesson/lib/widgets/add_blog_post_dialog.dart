import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog_app_lesson/data/blog_database.dart';
import 'package:firebase_blog_app_lesson/data/blog_post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddBlogPostDialog extends StatefulWidget {
  const AddBlogPostDialog({super.key});

  @override
  State<AddBlogPostDialog> createState() => _AddBlogPostDialogState();
}

class _AddBlogPostDialogState extends State<AddBlogPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descreptionController = TextEditingController();
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
            "Add Blog Post Here",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hint: Text("title ..."),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 4),
          TextField(
            controller: _descreptionController,
            maxLines: 5,
            minLines: 4,
            decoration: InputDecoration(
              hint: Text("description ..."),
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
              icon: Icon(Icons.image),
              iconSize: 40,
              color: Colors.lightBlueAccent,
            ),
          if (_image != null)
            Image.memory(_image!, height: 200, fit: BoxFit.cover),

          if (_isLoading == true) Center(child: CircularProgressIndicator()),
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
              child: Text("Cancle"),
            ),
            FilledButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_titleController.text.trim().isEmpty ||
                          _descreptionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orangeAccent,
                            content: Text(
                              "Please Filled Title and Description!",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      } else {
                        try {
                          setState(() {
                            _isLoading = true;
                          });
                          await _blogDatabase.createBlogPost(
                            BlogPostModel(
                              title: _titleController.text,
                              description: _descreptionController.text,
                              image: _image != null ? Blob(_image!) : null,
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  "Create Blog Post Sucessfully!",
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
                                  "Add Blog Post Failed! $e",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      }
                    },

              child: Text("Add Blog Post"),
            ),
          ],
        ),
      ],
    );
  }

  Future<XFile?> _pickImage() {
    ImagePicker imagePicker = ImagePicker();
    return imagePicker.pickImage(source: ImageSource.gallery);
  }
}
