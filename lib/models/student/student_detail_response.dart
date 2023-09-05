class StudentDetailResponse {
  List<GetstudentData>? getstudentData;
  dynamic feesRecipt;
  bool? success;
  int? errorCode;
  dynamic errorMessage;
  bool? token;
  bool? loginUserId;
  int? nUMBER;
  dynamic uSERNAME;
  dynamic pASSWORD;
  dynamic message;

  StudentDetailResponse(
      {this.getstudentData,
      this.feesRecipt,
      this.success,
      this.errorCode,
      this.errorMessage,
      this.token,
      this.loginUserId,
      this.nUMBER,
      this.uSERNAME,
      this.pASSWORD,
      this.message});

  StudentDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['GetstudentData'] != null) {
      getstudentData = <GetstudentData>[];
      json['GetstudentData'].forEach((v) {
        getstudentData!.add(GetstudentData.fromJson(v));
      });
    }
    feesRecipt = json['FeesRecipt'];
    success = json['Success'];
    errorCode = json['ErrorCode'];
    errorMessage = json['ErrorMessage'];
    token = json['Token'];
    loginUserId = json['LoginUserId'];
    nUMBER = json['NUMBER'];
    uSERNAME = json['USER_NAME'];
    pASSWORD = json['PASSWORD'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (getstudentData != null) {
      data['GetstudentData'] = getstudentData!.map((v) => v.toJson()).toList();
    }
    data['FeesRecipt'] = feesRecipt;
    data['Success'] = success;
    data['ErrorCode'] = errorCode;
    data['ErrorMessage'] = errorMessage;
    data['Token'] = token;
    data['LoginUserId'] = loginUserId;
    data['NUMBER'] = nUMBER;
    data['USER_NAME'] = uSERNAME;
    data['PASSWORD'] = pASSWORD;
    data['Message'] = message;
    return data;
  }
}

class GetstudentData {
  String? aDMNO;
  String? fIRSTNAME;
  String? lASTNAME;
  String? pARENTNAME;
  String? rELATIONSHIPDESC;
  String? sECTIONDESC;
  String? cLASSDESC;
  String? dATEOFBIRTH;
  String? gENDER;
  int? cLASSID;
  int? aDMSTUDENTID;
  bool? isChecked;
  int? cURRENTCLASSID;
  dynamic aADHARNO;
  dynamic sSSMID;
  dynamic fAMILYID;
  dynamic bANK;
  dynamic aCCOUNTNO;
  dynamic bANKCODE;
  dynamic bANKBRANCH;
  dynamic aCHOLDER;
  dynamic aCCOUNTTYPE;
  dynamic mICRNO;
  dynamic uNIQUENO;
  dynamic fATHERSSSMID;
  dynamic fATHERAADHAR;
  dynamic mOTHERSSSMID;
  dynamic mOTHERAADHAR;
  dynamic aDMSECTIONID;
  dynamic pREFIXID;
  dynamic pINCODE;
  dynamic eMERGENCYNO;
  dynamic pHONENO;
  dynamic bLOODGROUP;
  dynamic mOTHERTOUNGE;
  dynamic bIRTHPLACE;
  dynamic cITYID;
  dynamic mIDDLENAME;
  dynamic aDDRESS;
  dynamic pREVBOARDID;
  dynamic sESSIONID;
  dynamic sTUDTYPE;
  dynamic rELIGIONID;
  dynamic aDMSTUDRELATIVEID;
  dynamic cASTE;
  dynamic nOOFBROTHER;
  dynamic nOOFSISTER;
  dynamic sTUDENTTYPEID;
  dynamic aDMSESSIONID;
  dynamic tEACHERWARD;
  dynamic rELATIONID;
  dynamic fFIRSTNAME;
  dynamic fMIDDLENAME;
  dynamic fLASTNAME;
  dynamic fEMAILID;
  dynamic fMOBILENO;
  dynamic fPROFESSIONID;
  dynamic fORGANIZATION;
  dynamic fDESIGNATIONID;
  String? mOTHERFNAME;
  dynamic mOTHERMNAME;
  String? mOTHERLNAME;
  dynamic mOTHEREMAILID;
  dynamic mOTHERMOBNO;
  dynamic mOTHERPROFESSIONID;
  dynamic mOTHERORGANIZATION;
  dynamic mOTHERDESIGNATIONID;
  dynamic mOTHERANNUALINCOME;
  dynamic mOTHERRELATIONID;
  dynamic mOTHERPREFIXID;
  dynamic iSSUEDATE;
  dynamic sTATUS;
  dynamic rEGISTRATIONNO;
  int? cURRENTSECTIONID;
  dynamic sTUDPHOTO;
  dynamic mOTHERPHOTO;
  dynamic fPHOTO;
  dynamic gURDIANFNAME;
  dynamic gURDIANMNAME;
  dynamic gURDIANLNAME;
  dynamic gURDIANPREFIXID;
  dynamic gURDIANMOBNO;
  dynamic gURDIANEMAIL;
  dynamic gURDIANPHOTO;
  dynamic fee;
  dynamic aDMPRESTUDENTCHECKLISTID;
  dynamic aDMCHECKLISTID;
  dynamic cERTIFICATEDESC;
  dynamic cERTIFICATEID;
  dynamic pHOTO;
  dynamic rECIVED;
  dynamic dISCOUNT;
  dynamic fPREFIXID;
  String? sTUDENTTYPEDESC;
  dynamic cASTEDESC;
  String? aDMDATE;
  String? rELIGIONDESC;
  dynamic fATHEROCCUPATION;
  dynamic mOTHEROCCUPATION;
  dynamic gURDIANOCCUPATION;
  dynamic gURDIANANNUALINCOME;
  dynamic sUBJECTGROUP;
  dynamic cITYNAME;
  dynamic aNNUALINCOME;
  String? cASTECATEGORYDESC;
  dynamic fORMNO;
  String? rOLLNO;
  dynamic bOARDROLLNO;
  dynamic eNROLLMENTNO;
  dynamic bOARDREGNO;
  dynamic sTATEID;
  dynamic eMAIL;
  dynamic sTATENAME;
  dynamic sCHOLARNO;
  String? aCTIVE;
  dynamic sCHOOLID;
  dynamic sTUDENTCATEGORYID;
  dynamic cASTECATEGORYID;
  dynamic lstchecklist;
  dynamic aDMCLASSID;

  GetstudentData(
      {this.aDMNO,
      this.fIRSTNAME,
      this.lASTNAME,
      this.pARENTNAME,
      this.rELATIONSHIPDESC,
      this.sECTIONDESC,
      this.cLASSDESC,
      this.dATEOFBIRTH,
      this.gENDER,
      this.cLASSID,
      this.aDMSTUDENTID,
      this.isChecked,
      this.cURRENTCLASSID,
      this.aADHARNO,
      this.sSSMID,
      this.fAMILYID,
      this.bANK,
      this.aCCOUNTNO,
      this.bANKCODE,
      this.bANKBRANCH,
      this.aCHOLDER,
      this.aCCOUNTTYPE,
      this.mICRNO,
      this.uNIQUENO,
      this.fATHERSSSMID,
      this.fATHERAADHAR,
      this.mOTHERSSSMID,
      this.mOTHERAADHAR,
      this.aDMSECTIONID,
      this.pREFIXID,
      this.pINCODE,
      this.eMERGENCYNO,
      this.pHONENO,
      this.bLOODGROUP,
      this.mOTHERTOUNGE,
      this.bIRTHPLACE,
      this.cITYID,
      this.mIDDLENAME,
      this.aDDRESS,
      this.pREVBOARDID,
      this.sESSIONID,
      this.sTUDTYPE,
      this.rELIGIONID,
      this.aDMSTUDRELATIVEID,
      this.cASTE,
      this.nOOFBROTHER,
      this.nOOFSISTER,
      this.sTUDENTTYPEID,
      this.aDMSESSIONID,
      this.tEACHERWARD,
      this.rELATIONID,
      this.fFIRSTNAME,
      this.fMIDDLENAME,
      this.fLASTNAME,
      this.fEMAILID,
      this.fMOBILENO,
      this.fPROFESSIONID,
      this.fORGANIZATION,
      this.fDESIGNATIONID,
      this.mOTHERFNAME,
      this.mOTHERMNAME,
      this.mOTHERLNAME,
      this.mOTHEREMAILID,
      this.mOTHERMOBNO,
      this.mOTHERPROFESSIONID,
      this.mOTHERORGANIZATION,
      this.mOTHERDESIGNATIONID,
      this.mOTHERANNUALINCOME,
      this.mOTHERRELATIONID,
      this.mOTHERPREFIXID,
      this.iSSUEDATE,
      this.sTATUS,
      this.rEGISTRATIONNO,
      this.cURRENTSECTIONID,
      this.sTUDPHOTO,
      this.mOTHERPHOTO,
      this.fPHOTO,
      this.gURDIANFNAME,
      this.gURDIANMNAME,
      this.gURDIANLNAME,
      this.gURDIANPREFIXID,
      this.gURDIANMOBNO,
      this.gURDIANEMAIL,
      this.gURDIANPHOTO,
      this.fee,
      this.aDMPRESTUDENTCHECKLISTID,
      this.aDMCHECKLISTID,
      this.cERTIFICATEDESC,
      this.cERTIFICATEID,
      this.pHOTO,
      this.rECIVED,
      this.dISCOUNT,
      this.fPREFIXID,
      this.sTUDENTTYPEDESC,
      this.cASTEDESC,
      this.aDMDATE,
      this.rELIGIONDESC,
      this.fATHEROCCUPATION,
      this.mOTHEROCCUPATION,
      this.gURDIANOCCUPATION,
      this.gURDIANANNUALINCOME,
      this.sUBJECTGROUP,
      this.cITYNAME,
      this.aNNUALINCOME,
      this.cASTECATEGORYDESC,
      this.fORMNO,
      this.rOLLNO,
      this.bOARDROLLNO,
      this.eNROLLMENTNO,
      this.bOARDREGNO,
      this.sTATEID,
      this.eMAIL,
      this.sTATENAME,
      this.sCHOLARNO,
      this.aCTIVE,
      this.sCHOOLID,
      this.sTUDENTCATEGORYID,
      this.cASTECATEGORYID,
      this.lstchecklist,
      this.aDMCLASSID});

  GetstudentData.fromJson(Map<String, dynamic> json) {
    aDMNO = json['ADM_NO'];
    fIRSTNAME = json['FIRST_NAME'];
    lASTNAME = json['LAST_NAME'];
    pARENTNAME = json['PARENTNAME'];
    rELATIONSHIPDESC = json['RELATIONSHIP_DESC'];
    sECTIONDESC = json['SECTION_DESC'];
    cLASSDESC = json['CLASS_DESC'];
    dATEOFBIRTH = json['DATE_OF_BIRTH'];
    gENDER = json['GENDER'];
    cLASSID = json['CLASS_ID'];
    aDMSTUDENTID = json['ADM_STUDENT_ID'];
    isChecked = json['isChecked'];
    cURRENTCLASSID = json['CURRENT_CLASS_ID'];
    aADHARNO = json['AADHAR_NO'];
    sSSMID = json['SSSM_ID'];
    fAMILYID = json['FAMILY_ID'];
    bANK = json['BANK'];
    aCCOUNTNO = json['ACCOUNT_NO'];
    bANKCODE = json['BANK_CODE'];
    bANKBRANCH = json['BANK_BRANCH'];
    aCHOLDER = json['AC_HOLDER'];
    aCCOUNTTYPE = json['ACCOUNT_TYPE'];
    mICRNO = json['MICR_NO'];
    uNIQUENO = json['UNIQUE_NO'];
    fATHERSSSMID = json['FATHER_SSSMID'];
    fATHERAADHAR = json['FATHER_AADHAR'];
    mOTHERSSSMID = json['MOTHER_SSSMID'];
    mOTHERAADHAR = json['MOTHER_AADHAR'];
    aDMSECTIONID = json['ADM_SECTION_ID'];
    pREFIXID = json['PREFIX_ID'];
    pINCODE = json['PINCODE'];
    eMERGENCYNO = json['EMERGENCY_NO'];
    pHONENO = json['PHONE_NO'];
    bLOODGROUP = json['BLOODGROUP'];
    mOTHERTOUNGE = json['MOTHER_TOUNGE'];
    bIRTHPLACE = json['BIRTHPLACE'];
    cITYID = json['CITY_ID'];
    mIDDLENAME = json['MIDDLE_NAME'];
    aDDRESS = json['ADDRESS'];
    pREVBOARDID = json['PREV_BOARD_ID'];
    sESSIONID = json['SESSION_ID'];
    sTUDTYPE = json['STUD_TYPE'];
    rELIGIONID = json['RELIGION_ID'];
    aDMSTUDRELATIVEID = json['ADM_STUD_RELATIVE_ID'];
    cASTE = json['CASTE'];
    nOOFBROTHER = json['NO_OF_BROTHER'];
    nOOFSISTER = json['NO_OF_SISTER'];
    sTUDENTTYPEID = json['STUDENT_TYPE_ID'];
    aDMSESSIONID = json['ADM_SESSION_ID'];
    tEACHERWARD = json['TEACHER_WARD'];
    rELATIONID = json['RELATION_ID'];
    fFIRSTNAME = json['F_FIRST_NAME'];
    fMIDDLENAME = json['F_MIDDLE_NAME'];
    fLASTNAME = json['F_LAST_NAME'];
    fEMAILID = json['F_EMAIL_ID'];
    fMOBILENO = json['F_MOBILE_NO'];
    fPROFESSIONID = json['F_PROFESSION_ID'];
    fORGANIZATION = json['F_ORGANIZATION'];
    fDESIGNATIONID = json['F_DESIGNATION_ID'];
    mOTHERFNAME = json['MOTHER_F_NAME'];
    mOTHERMNAME = json['MOTHER_M_NAME'];
    mOTHERLNAME = json['MOTHER_L_NAME'];
    mOTHEREMAILID = json['MOTHER_EMAIL_ID'];
    mOTHERMOBNO = json['MOTHER_MOB_NO'];
    mOTHERPROFESSIONID = json['MOTHER_PROFESSION_ID'];
    mOTHERORGANIZATION = json['MOTHER_ORGANIZATION'];
    mOTHERDESIGNATIONID = json['MOTHER_DESIGNATION_ID'];
    mOTHERANNUALINCOME = json['MOTHER_ANNUAL_INCOME'];
    mOTHERRELATIONID = json['MOTHER_RELATION_ID'];
    mOTHERPREFIXID = json['MOTHER_PREFIX_ID'];
    iSSUEDATE = json['ISSUE_DATE'];
    sTATUS = json['STATUS'];
    rEGISTRATIONNO = json['REGISTRATION_NO'];
    cURRENTSECTIONID = json['CURRENT_SECTION_ID'];
    sTUDPHOTO = json['STUD_PHOTO'];
    mOTHERPHOTO = json['MOTHER_PHOTO'];
    fPHOTO = json['F_PHOTO'];
    gURDIANFNAME = json['GURDIAN_F_NAME'];
    gURDIANMNAME = json['GURDIAN_M_NAME'];
    gURDIANLNAME = json['GURDIAN_L_NAME'];
    gURDIANPREFIXID = json['GURDIAN_PREFIX_ID'];
    gURDIANMOBNO = json['GURDIAN_MOB_NO'];
    gURDIANEMAIL = json['GURDIAN_EMAIL'];
    gURDIANPHOTO = json['GURDIAN_PHOTO'];
    fee = json['Fee'];
    aDMPRESTUDENTCHECKLISTID = json['ADM_PRESTUDENT_CHECKLIST_ID'];
    aDMCHECKLISTID = json['ADM_CHECKLIST_ID'];
    cERTIFICATEDESC = json['CERTIFICATE_DESC'];
    cERTIFICATEID = json['CERTIFICATE_ID'];
    pHOTO = json['PHOTO'];
    rECIVED = json['RECIVED'];
    dISCOUNT = json['DISCOUNT'];
    fPREFIXID = json['F_PREFIX_ID'];
    sTUDENTTYPEDESC = json['STUDENT_TYPE_DESC'];
    cASTEDESC = json['CASTE_DESC'];
    aDMDATE = json['ADM_DATE'];
    rELIGIONDESC = json['RELIGION_DESC'];
    fATHEROCCUPATION = json['FATHER_OCCUPATION'];
    mOTHEROCCUPATION = json['MOTHER_OCCUPATION'];
    gURDIANOCCUPATION = json['GURDIAN_OCCUPATION'];
    gURDIANANNUALINCOME = json['GURDIAN_ANNUAL_INCOME'];
    sUBJECTGROUP = json['SUBJECT_GROUP'];
    cITYNAME = json['CITY_NAME'];
    aNNUALINCOME = json['ANNUAL_INCOME'];
    cASTECATEGORYDESC = json['CASTE_CATEGORY_DESC'];
    fORMNO = json['FORMNO'];
    rOLLNO = json['ROLL_NO'];
    bOARDROLLNO = json['BOARD_ROLL_NO'];
    eNROLLMENTNO = json['ENROLLMENT_NO'];
    bOARDREGNO = json['BOARD_REG_NO'];
    sTATEID = json['STATE_ID'];
    pHONENO = json['PHONENO'];
    eMAIL = json['EMAIL'];
    sTATENAME = json['STATE_NAME'];
    sCHOLARNO = json['SCHOLAR_NO'];
    aCTIVE = json['ACTIVE'];
    sCHOOLID = json['SCHOOL_ID'];
    sTUDENTCATEGORYID = json['STUDENT_CATEGORY_ID'];
    cASTECATEGORYID = json['CASTE_CATEGORY_ID'];
    lstchecklist = json['lstchecklist'];
    aDMCLASSID = json['ADM_CLASS_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ADM_NO'] = aDMNO;
    data['FIRST_NAME'] = fIRSTNAME;
    data['LAST_NAME'] = lASTNAME;
    data['PARENTNAME'] = pARENTNAME;
    data['RELATIONSHIP_DESC'] = rELATIONSHIPDESC;
    data['SECTION_DESC'] = sECTIONDESC;
    data['CLASS_DESC'] = cLASSDESC;
    data['DATE_OF_BIRTH'] = dATEOFBIRTH;
    data['GENDER'] = gENDER;
    data['CLASS_ID'] = cLASSID;
    data['ADM_STUDENT_ID'] = aDMSTUDENTID;
    data['isChecked'] = isChecked;
    data['CURRENT_CLASS_ID'] = cURRENTCLASSID;
    data['AADHAR_NO'] = aADHARNO;
    data['SSSM_ID'] = sSSMID;
    data['FAMILY_ID'] = fAMILYID;
    data['BANK'] = bANK;
    data['ACCOUNT_NO'] = aCCOUNTNO;
    data['BANK_CODE'] = bANKCODE;
    data['BANK_BRANCH'] = bANKBRANCH;
    data['AC_HOLDER'] = aCHOLDER;
    data['ACCOUNT_TYPE'] = aCCOUNTTYPE;
    data['MICR_NO'] = mICRNO;
    data['UNIQUE_NO'] = uNIQUENO;
    data['FATHER_SSSMID'] = fATHERSSSMID;
    data['FATHER_AADHAR'] = fATHERAADHAR;
    data['MOTHER_SSSMID'] = mOTHERSSSMID;
    data['MOTHER_AADHAR'] = mOTHERAADHAR;
    data['ADM_SECTION_ID'] = aDMSECTIONID;
    data['PREFIX_ID'] = pREFIXID;
    data['PINCODE'] = pINCODE;
    data['EMERGENCY_NO'] = eMERGENCYNO;
    data['PHONE_NO'] = pHONENO;
    data['BLOODGROUP'] = bLOODGROUP;
    data['MOTHER_TOUNGE'] = mOTHERTOUNGE;
    data['BIRTHPLACE'] = bIRTHPLACE;
    data['CITY_ID'] = cITYID;
    data['MIDDLE_NAME'] = mIDDLENAME;
    data['ADDRESS'] = aDDRESS;
    data['PREV_BOARD_ID'] = pREVBOARDID;
    data['SESSION_ID'] = sESSIONID;
    data['STUD_TYPE'] = sTUDTYPE;
    data['RELIGION_ID'] = rELIGIONID;
    data['ADM_STUD_RELATIVE_ID'] = aDMSTUDRELATIVEID;
    data['CASTE'] = cASTE;
    data['NO_OF_BROTHER'] = nOOFBROTHER;
    data['NO_OF_SISTER'] = nOOFSISTER;
    data['STUDENT_TYPE_ID'] = sTUDENTTYPEID;
    data['ADM_SESSION_ID'] = aDMSESSIONID;
    data['TEACHER_WARD'] = tEACHERWARD;
    data['RELATION_ID'] = rELATIONID;
    data['F_FIRST_NAME'] = fFIRSTNAME;
    data['F_MIDDLE_NAME'] = fMIDDLENAME;
    data['F_LAST_NAME'] = fLASTNAME;
    data['F_EMAIL_ID'] = fEMAILID;
    data['F_MOBILE_NO'] = fMOBILENO;
    data['F_PROFESSION_ID'] = fPROFESSIONID;
    data['F_ORGANIZATION'] = fORGANIZATION;
    data['F_DESIGNATION_ID'] = fDESIGNATIONID;
    data['MOTHER_F_NAME'] = mOTHERFNAME;
    data['MOTHER_M_NAME'] = mOTHERMNAME;
    data['MOTHER_L_NAME'] = mOTHERLNAME;
    data['MOTHER_EMAIL_ID'] = mOTHEREMAILID;
    data['MOTHER_MOB_NO'] = mOTHERMOBNO;
    data['MOTHER_PROFESSION_ID'] = mOTHERPROFESSIONID;
    data['MOTHER_ORGANIZATION'] = mOTHERORGANIZATION;
    data['MOTHER_DESIGNATION_ID'] = mOTHERDESIGNATIONID;
    data['MOTHER_ANNUAL_INCOME'] = mOTHERANNUALINCOME;
    data['MOTHER_RELATION_ID'] = mOTHERRELATIONID;
    data['MOTHER_PREFIX_ID'] = mOTHERPREFIXID;
    data['ISSUE_DATE'] = iSSUEDATE;
    data['STATUS'] = sTATUS;
    data['REGISTRATION_NO'] = rEGISTRATIONNO;
    data['CURRENT_SECTION_ID'] = cURRENTSECTIONID;
    data['STUD_PHOTO'] = sTUDPHOTO;
    data['MOTHER_PHOTO'] = mOTHERPHOTO;
    data['F_PHOTO'] = fPHOTO;
    data['GURDIAN_F_NAME'] = gURDIANFNAME;
    data['GURDIAN_M_NAME'] = gURDIANMNAME;
    data['GURDIAN_L_NAME'] = gURDIANLNAME;
    data['GURDIAN_PREFIX_ID'] = gURDIANPREFIXID;
    data['GURDIAN_MOB_NO'] = gURDIANMOBNO;
    data['GURDIAN_EMAIL'] = gURDIANEMAIL;
    data['GURDIAN_PHOTO'] = gURDIANPHOTO;
    data['Fee'] = fee;
    data['ADM_PRESTUDENT_CHECKLIST_ID'] = aDMPRESTUDENTCHECKLISTID;
    data['ADM_CHECKLIST_ID'] = aDMCHECKLISTID;
    data['CERTIFICATE_DESC'] = cERTIFICATEDESC;
    data['CERTIFICATE_ID'] = cERTIFICATEID;
    data['PHOTO'] = pHOTO;
    data['RECIVED'] = rECIVED;
    data['DISCOUNT'] = dISCOUNT;
    data['F_PREFIX_ID'] = fPREFIXID;
    data['STUDENT_TYPE_DESC'] = sTUDENTTYPEDESC;
    data['CASTE_DESC'] = cASTEDESC;
    data['ADM_DATE'] = aDMDATE;
    data['RELIGION_DESC'] = rELIGIONDESC;
    data['FATHER_OCCUPATION'] = fATHEROCCUPATION;
    data['MOTHER_OCCUPATION'] = mOTHEROCCUPATION;
    data['GURDIAN_OCCUPATION'] = gURDIANOCCUPATION;
    data['GURDIAN_ANNUAL_INCOME'] = gURDIANANNUALINCOME;
    data['SUBJECT_GROUP'] = sUBJECTGROUP;
    data['CITY_NAME'] = cITYNAME;
    data['ANNUAL_INCOME'] = aNNUALINCOME;
    data['CASTE_CATEGORY_DESC'] = cASTECATEGORYDESC;
    data['FORMNO'] = fORMNO;
    data['ROLL_NO'] = rOLLNO;
    data['BOARD_ROLL_NO'] = bOARDROLLNO;
    data['ENROLLMENT_NO'] = eNROLLMENTNO;
    data['BOARD_REG_NO'] = bOARDREGNO;
    data['STATE_ID'] = sTATEID;
    data['PHONENO'] = pHONENO;
    data['EMAIL'] = eMAIL;
    data['STATE_NAME'] = sTATENAME;
    data['SCHOLAR_NO'] = sCHOLARNO;
    data['ACTIVE'] = aCTIVE;
    data['SCHOOL_ID'] = sCHOOLID;
    data['STUDENT_CATEGORY_ID'] = sTUDENTCATEGORYID;
    data['CASTE_CATEGORY_ID'] = cASTECATEGORYID;
    data['lstchecklist'] = lstchecklist;
    data['ADM_CLASS_ID'] = aDMCLASSID;
    return data;
  }
}
