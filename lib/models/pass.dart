class Pass {
  String? sId;
  String? requestedBy;
  String? agentCode;
  String? passType;
  String? passCode;
  String? fullName;
  String? gender;
  String? dob;
  String? mobile;
  String? idProofUrl;
  String? profilePhotoUrl;
  int? amount;
  bool? isAmountPaid;
  String? paymentRefId;
  String? fromDate;
  String? toDate;
  String? status;
  List<String>? rejectionReason;
  String? createdAt;
  String? updatedAt;

  Pass({
    this.sId,
    this.requestedBy,
    this.agentCode,
    this.passType,
    this.passCode,
    this.fullName,
    this.gender,
    this.dob,
    this.mobile,
    this.idProofUrl,
    this.profilePhotoUrl,
    this.amount,
    this.isAmountPaid,
    this.paymentRefId,
    this.fromDate,
    this.toDate,
    this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  Pass.fromJson(Map<String, dynamic> mainJson) {
    final json = mainJson['pass'] ?? mainJson['passes'][0] ?? mainJson;
    sId = json['_id'];
    requestedBy = json['requestedBy'];
    agentCode = json['agentCode'];
    passType = json['passType'];
    passCode = json['passCode'];
    fullName = json['fullName'];
    gender = json['gender'];
    dob = json['dob'];
    mobile = json['mobile'];
    idProofUrl = json['idProofUrl'];
    profilePhotoUrl = json['profilePhotoUrl'];
    amount = json['amount'];
    isAmountPaid = json['isAmountPaid'];
    paymentRefId = json['paymentRefId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    status = json['status'];
    rejectionReason = json['rejectionReason'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
