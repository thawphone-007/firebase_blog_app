import 'package:cloud_firestore/cloud_firestore.dart';

import 'blog_post_model.dart';

class BlogDatabase {
  // ***** CREATE BLOGS POST ON FIREBASE FIRESTORE
  final CollectionReference<BlogPostModel> _blogCollection = FirebaseFirestore
      .instance
      .collection("blogs")
      .withConverter(
        fromFirestore: (snapshot, _) => BlogPostModel.fromJson(snapshot),
        toFirestore: (blogPostModel, _) => blogPostModel.toJson(),
      );

  Future<DocumentReference<BlogPostModel>> createBlogPost({
    required BlogPostModel blogPostModel,
  }) async {
    try {
      DateTime now = DateTime.now();
      return await _blogCollection.add(
        blogPostModel.copyWith(createdAt: now.millisecondsSinceEpoch),
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  // ***** READ BLOG POST FORM FIREBASE FIRESTORE
  late final Stream<QuerySnapshot<BlogPostModel>> _blogPostStream =
      _blogCollection.snapshots();

  Stream<QuerySnapshot<BlogPostModel>> readBlogPost() {
    try {
      return _blogPostStream;
    } catch (e) {
      return Stream.error(e);
    }
  }

  // ***** DELETE BLOG DOCUMENT FORM FIREBASE FIRESTORE
  Future<void> deleteBlogPost(String docId) async {
    try {
      return await _blogCollection.doc(docId).delete();
    } catch (e) {
      return Future.error(e);
    }
  }

  // ***** UPDATE BLOG POST ON FIREBASE FIRESTORE
  Future<void> updateBlogPost({
    required BlogPostModel blogPostModel,
    required String docId,
  }) async {
    try {
      DateTime now = DateTime.now();
      return await _blogCollection
          .doc(docId)
          .update(
            blogPostModel
                .copyWith(updatedAt: now.millisecondsSinceEpoch)
                .toJson(),
          );
    } catch (e) {
      Future.error(e);
    }
  }
}
