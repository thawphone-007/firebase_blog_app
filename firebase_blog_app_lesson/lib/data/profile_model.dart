class ProfileModel {
  ProfileModel({this.name, this.userId, this.email, this.profilePicture});

  ProfileModel.fromJson(dynamic json) {
    name = json['name'];
    userId = json['userId'];
    email = json['email'];
    profilePicture = json['profilePicture'];
  }

  String? name;
  String? userId;
  String? email;
  String? profilePicture;

  ProfileModel copyWith({
    String? name,
    String? userId,
    String? email,
    String? profilePicture,
  }) => ProfileModel(
    name: name ?? this.name,
    userId: userId ?? this.userId,
    email: email ?? this.email,
    profilePicture: profilePicture ?? this.profilePicture,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['userId'] = userId;
    map['email'] = email;
    map['profilePicture'] = profilePicture;
    return map;
  }
}
