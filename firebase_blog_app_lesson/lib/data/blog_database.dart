import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog_app_lesson/data/blog_post_model.dart';

class BlogDatabase {
  // ***** Create Database "blogs" Collection on FirebaseFirestore And Add Documents
  final CollectionReference<BlogPostModel> _blogCollection = FirebaseFirestore
      .instance
      .collection("blogs")
      .withConverter(
        fromFirestore: (snapshot, options) => BlogPostModel.fromJson(snapshot),
        toFirestore: (blogPostModel, _) => blogPostModel.toJson(),
      );

  Future<DocumentReference> createBlogPost(BlogPostModel blogPostModel) async {
    try {
      DateTime now = DateTime.now();
      return await _blogCollection.add(
        blogPostModel.copyWith(createdAt: now.millisecondsSinceEpoch),
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  // ***** Read Collection Database From FirebaseFirestore
  late final Stream<QuerySnapshot<BlogPostModel>> _blogPostStream =
      _blogCollection.snapshots();

  Stream<QuerySnapshot<BlogPostModel>> readBlogList() {
    try {
      return _blogPostStream;
    } catch (e) {
      return Stream.error(e);
    }
  }

  // ***** Delete Document with DocumentId From FirebaseFirestore's Collection
  Future<void> deleteBlogPost(String docId) async {
    try {
      return await _blogCollection.doc(docId).delete();
    } catch (e) {
      return Future.error(e);
    }
  }

  // ***** Update Document with DocumentId From FirebaseFirestore's Collection
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
      return Future.error(e);
    }
  }
}
