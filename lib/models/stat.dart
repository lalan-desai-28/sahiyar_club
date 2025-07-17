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
  CurrentFeeBatch? currentFeeBatch;

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
    this.currentFeeBatch,
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
    currentFeeBatch =
        json['currentFeeBatch'] != null
            ? CurrentFeeBatch.fromJson(json['currentFeeBatch'])
            : null;
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
    if (currentFeeBatch != null) {
      data['currentFeeBatch'] = currentFeeBatch!.toJson();
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
  bool? shouldShowMRP;

  CurrentFeeBatch({
    this.batchType,
    this.batchName,
    this.maleFee,
    this.femaleFee,
    this.kidFee,
    this.shouldShowMRP = false,
  });

  CurrentFeeBatch.fromJson(Map<String, dynamic> json) {
    batchType = json['batchType'];
    batchName = json['batchName'];
    maleFee = json['maleFee'];
    femaleFee = json['femaleFee'];
    kidFee = json['kidFee'];
    shouldShowMRP = json['showDiscountedPrice'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['batchType'] = batchType;
    data['batchName'] = batchName;
    data['maleFee'] = maleFee;
    data['femaleFee'] = femaleFee;
    data['kidFee'] = kidFee;
    return data;
  }
}
