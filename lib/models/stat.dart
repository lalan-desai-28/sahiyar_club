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
    return data;
  }
}
