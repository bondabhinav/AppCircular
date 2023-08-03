class Api {
  static String baseUrl = "https://flexierpapi.sapinfotek.com/API/";
  static String imageBaseUrl = "https://flexierpapi.sapinfotek.com/";

  static String getClassApi = "${baseUrl}GetClassforAssignment/GetClassandSectionforAssignment";
  static String getSectionApi = "${baseUrl}GetSectionforAssignment/GetClassandSectionforAssignment";
  static String getStudentApi = "${baseUrl}GetStudentbyClassandSection/getstudent";
  static String uploadFileApi = "${baseUrl}Fileupload/UploadFile";
  static String addCircularApi = "${baseUrl}Circular/AddCircular";
  static String studentCircularListApi = "${baseUrl}GetCircularByorder/GetCircularByorder";
  static String studentDocumentListApi = "${baseUrl}ViewCircularAttachment/ViewCircularAttachment";
  static String deleteCircularFileApi = "${baseUrl}FiledeleteCircular/UploadFile";
  static String updateCircularFlagApi = "${baseUrl}CircularFlagUpdate/CircularFlagUpdat";
  static String getTeacherCircularListApi = "${baseUrl}GetCircularFromDatetoTodate/GetCircularFromDatetoTodate";
  static String applyAttendanceApi = "${baseUrl}CreateAttendance/CreateAttendance";
  static String studentDetailApi = "${baseUrl}StudentSearch/studentData";
  static String studentSessionApi = "${baseUrl}SessionAPP/GetSessionByADMNo";
}
