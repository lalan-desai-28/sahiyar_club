class User {
  bool? isActive;
  bool? isDeleted;
  String? id;
  String? firstName;
  String? lastName;
  String? nickName;
  String? email;
  String? mobile;
  String? gender;
  String? role;
  String? agentCode;
  String? token;
  String? fullName;

  User({
    this.isActive,
    this.isDeleted,
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.nickName,
    this.mobile,
    this.gender,
    this.role,
    this.agentCode,
    this.token,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userJson =
        (json['data'] is Map && json['data']['user'] != null)
            ? json['data']['user']
            : json;

    // Split fullName into first and last names
    String? fullName = userJson['fullName'];
    String? firstName;
    String? lastName;

    if (fullName != null) {
      final parts = fullName.trim().split(' ');
      firstName = parts.isNotEmpty ? parts.first : null;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
      fullName = fullName.trim();
    }

    return User(
      isActive: userJson['isActive'],
      isDeleted: userJson['isDeleted'],
      id: userJson['_id'],
      firstName: firstName,
      lastName: lastName,
      email: userJson['email'],
      mobile: userJson['mobile'],
      gender: userJson['gender'],
      nickName: userJson['nickName'],
      fullName: fullName,
      role: userJson['role'],
      agentCode: userJson['agentCode'],
      token:
          json['token'] ??
          (json['data'] is Map ? json['data']['token'] : '') ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'isDeleted': isDeleted,
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'nickName': nickName,
      'gender': gender,
      'role': role,
      'agentCode': agentCode,
      'token': token,
    };
  }
}
