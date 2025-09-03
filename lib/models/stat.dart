class Stat {
  int? totalPasses;
  int? approvedPasses;
  int? rejectedPasses;
  int? pendingPasses;
  int? inRequestPasses;
  int? issuedPasses;
  int? printedPasses;
  int? cancelledPasses;
  int? totalMalePasses;
  int? totalFemalePasses;
  int? totalKidPasses;
  int? totalMaleCollectedFees;
  int? totalFemaleCollectedFees;
  int? totalKidCollectedFees;
  CurrentFeeBatch? currentFeeBatch;
  List<SubAgentStats>? subAgentStats;

  Stat({
    this.totalPasses,
    this.approvedPasses,
    this.rejectedPasses,
    this.pendingPasses,
    this.inRequestPasses,
    this.issuedPasses,
    this.printedPasses,
    this.cancelledPasses,
    this.totalMalePasses,
    this.totalFemalePasses,
    this.totalKidPasses,
    this.totalMaleCollectedFees,
    this.totalFemaleCollectedFees,
    this.totalKidCollectedFees,
    this.currentFeeBatch,
    this.subAgentStats,
  });

  Stat.fromJson(Map<String, dynamic> json) {
    totalPasses = json['totalPasses'];
    approvedPasses = json['approvedPasses'];
    rejectedPasses = json['rejectedPasses'];
    pendingPasses = json['pendingPasses'];
    inRequestPasses = json['inRequestPasses'];
    issuedPasses = json['issuedPasses'];
    printedPasses = json['printedPasses'];
    cancelledPasses = json['cancelledPasses'];
    totalMalePasses = json['totalMalePasses'];
    totalFemalePasses = json['totalFemalePasses'];
    totalKidPasses = json['totalKidPasses'];
    totalMaleCollectedFees = json['totalMaleCollectedFees'];
    totalFemaleCollectedFees = json['totalFemaleCollectedFees'];
    totalKidCollectedFees = json['totalKidCollectedFees'];
    currentFeeBatch =
        json['currentFeeBatch'] != null
            ? CurrentFeeBatch.fromJson(json['currentFeeBatch'])
            : null;
    if (json['subAgentStats'] != null) {
      subAgentStats = <SubAgentStats>[];
      json['subAgentStats'].forEach((v) {
        subAgentStats!.add(SubAgentStats.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalPasses'] = totalPasses;
    data['approvedPasses'] = approvedPasses;
    data['rejectedPasses'] = rejectedPasses;
    data['pendingPasses'] = pendingPasses;
    data['inRequestPasses'] = inRequestPasses;
    data['issuedPasses'] = issuedPasses;
    data['printedPasses'] = printedPasses;
    data['cancelledPasses'] = cancelledPasses;
    data['totalMalePasses'] = totalMalePasses;
    data['totalFemalePasses'] = totalFemalePasses;
    data['totalKidPasses'] = totalKidPasses;
    data['totalMaleCollectedFees'] = totalMaleCollectedFees;
    data['totalFemaleCollectedFees'] = totalFemaleCollectedFees;
    data['totalKidCollectedFees'] = totalKidCollectedFees;
    if (currentFeeBatch != null) {
      data['currentFeeBatch'] = currentFeeBatch!.toJson();
    }
    if (subAgentStats != null) {
      data['subAgentStats'] = subAgentStats!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrentFeeBatch {
  String? batchType;
  String? batchName;
  int? maleFee;
  int? femaleFee;
  int? kidFee;
  int? kidMrp;
  int? femaleMrp;
  int? maleMrp;
  bool? showDiscountedPrice;

  CurrentFeeBatch({
    this.batchType,
    this.batchName,
    this.maleFee,
    this.femaleFee,
    this.kidFee,
    this.showDiscountedPrice,
    this.kidMrp,
    this.femaleMrp,
    this.maleMrp,
  });

  CurrentFeeBatch.fromJson(Map<String, dynamic> json) {
    batchType = json['batchType'];
    batchName = json['batchName'];
    maleFee = json['maleFee'];
    femaleFee = json['femaleFee'];
    kidFee = json['kidFee'];
    showDiscountedPrice = json['showDiscountedPrice'];
    femaleMrp = json['femaleMrp'];
    maleMrp = json['maleMrp'];
    kidMrp = json['kidMrp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['batchType'] = batchType;
    data['batchName'] = batchName;
    data['maleFee'] = maleFee;
    data['femaleFee'] = femaleFee;
    data['kidFee'] = kidFee;
    data['showDiscountedPrice'] = showDiscountedPrice;
    data['femaleMrp'] = femaleMrp;
    data['maleMrp'] = maleMrp;
    data['kidMrp'] = kidMrp;
    return data;
  }
}

class SubAgentStats {
  String? subAgentId;
  String? subAgentCode;
  int? passCount;

  SubAgentStats({this.subAgentId, this.subAgentCode, this.passCount});

  SubAgentStats.fromJson(Map<String, dynamic> json) {
    subAgentId = json['subAgentId'];
    subAgentCode = json['subAgentCode'];
    passCount = json['passCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subAgentId'] = subAgentId;
    data['subAgentCode'] = subAgentCode;
    data['passCount'] = passCount;
    return data;
  }
}
