import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog_app_lesson/data/blog_database.dart';
import 'package:firebase_blog_app_lesson/data/blog_post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditBlogPostDialog extends StatefulWidget {
  const EditBlogPostDialog({
    super.key,
    required this.docId,
    required this.blogPostModel,
  });

  final String docId;
  final BlogPostModel blogPostModel;

  @override
  State<EditBlogPostDialog> createState() => _EditBlogPostDialogState();
}

class _EditBlogPostDialogState extends State<EditBlogPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descreptionController = TextEditingController();
  final BlogDatabase _blogDatabase = BlogDatabase();
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.blogPostModel.title ?? "";
    _descreptionController.text = widget.blogPostModel.description ?? "";
    _image = widget.blogPostModel.image?.bytes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Edit Blog Post Here",
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
          if (_image == null)
            IconButton(
              onPressed: () async {
                _editPhoto();
              },
              icon: Icon(Icons.image, size: 36, color: Colors.lightBlueAccent),
            ),
          if (_image != null)
            Image.memory(_image!, height: 200, fit: BoxFit.cover),
          SizedBox(height: 4),
          if (_image != null)
            TextButton(
              onPressed: () async {
                _editPhoto();
              },
              child: Text("Edit Photo"),
            ),
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
                          await _blogDatabase.updateBlogPost(
                            docId: widget.docId,
                            blogPostModel: BlogPostModel(
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
                                  "Edit Blog Post Sucessfully!",
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
                                  "Edit Blog Post Failed! $e",
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
              child: Text("Edit Blog Post"),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editPhoto() async {
    XFile? image = await _pickImage();
    if (image != null) {
      _image = await image.readAsBytes();
      setState(() {});
    }
  }

  Future<XFile?> _pickImage() {
    ImagePicker imagePicker = ImagePicker();
    return imagePicker.pickImage(source: ImageSource.gallery);
  }
}
