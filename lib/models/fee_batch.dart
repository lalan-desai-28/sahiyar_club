class FeeBatch {
  String? sId;
  String? batchName;
  String? batchType;
  String? validFrom;
  String? validTo;
  int? maleFee;
  int? maleMrp;
  int? femaleFee;
  int? femaleMrp;
  int? kidFee;
  int? kidMrp;
  bool? active;
  String? createdBy;
  String? createdAt;
  String? updatedAt;

  FeeBatch({
    this.sId,
    this.batchName,
    this.batchType,
    this.validFrom,
    this.validTo,
    this.maleFee,
    this.maleMrp,
    this.femaleFee,
    this.femaleMrp,
    this.kidFee,
    this.kidMrp,
    this.active,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  FeeBatch.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    batchName = json['batchName'];
    batchType = json['batchType'];
    validFrom = json['validFrom'];
    validTo = json['validTo'];
    maleFee = json['maleFee'];
    maleMrp = json['maleMrp'];
    femaleFee = json['femaleFee'];
    femaleMrp = json['femaleMrp'];
    kidFee = json['kidFee'];
    kidMrp = json['kidMrp'];
    active = json['active'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['batchName'] = batchName;
    data['batchType'] = batchType;
    data['validFrom'] = validFrom;
    data['validTo'] = validTo;
    data['maleFee'] = maleFee;
    data['maleMrp'] = maleMrp;
    data['femaleFee'] = femaleFee;
    data['femaleMrp'] = femaleMrp;
    data['kidFee'] = kidFee;
    data['kidMrp'] = kidMrp;
    data['active'] = active;
    data['createdBy'] = createdBy;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
