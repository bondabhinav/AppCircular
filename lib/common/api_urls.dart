class Api {
  static String baseUrl = "";
  static String imageBaseUrl = "";

  static String getClassApi = "${baseUrl}GetClassforAssignment/GetClassandSectionforAssignment";
  static String getSectionApi = "${baseUrl}GetSectionforAssignment/GetClassandSectionforAssignment";
  static String getStudentApi = "${baseUrl}GetStudentbyClassandSection/getstudent";
  static String addCircularApi = "${baseUrl}Circular/AddCircular";
  static String studentCircularListApi = "${baseUrl}GetCircularByorder/GetCircularByorder";
  static String studentDocumentListApi = "${baseUrl}ViewCircularAttachment/ViewCircularAttachment";
  static String deleteCircularFileApi = "${baseUrl}FiledeleteCircular/UploadFile";
  static String deleteAssignmentFileApi = "${baseUrl}FiledeleteAssignment/UploadFile";
  static String updateCircularFlagApi = "${baseUrl}CircularFlagUpdate/CircularFlagUpdat";
  static String getTeacherCircularListApi = "${baseUrl}GetCircularFromDatetoTodate/GetCircularFromDatetoTodate";
  static String applyAttendanceApi = "${baseUrl}CreateAttendance/CreateAttendance";
  static String studentDetailApi = "${baseUrl}StudentSearch/studentData";
  static String studentSessionApi = "${baseUrl}SessionAPP/GetSessionByADMNo";
  static String getSubjectApi = "${baseUrl}GetSubjectforAssignment/GetSubjectforAssignmentbyClassSecTeacher";
  static String addAssignmentApi = "${baseUrl}Assignment/AddAssignment";
  static String notificationCountApi = "${baseUrl}NotificationCount/NotificationCount";
  static String notificationListApi = "${baseUrl}Notification/GetNotification";
  static String uploadCircularImageDocFileApi = "${baseUrl}FileuploadCircular/UploadFile";
  static String uploadAssignmentImageDocFileApi = "${baseUrl}FileuploadAssignment/UploadFile";
  static String getAssignmentByDateApi = "${baseUrl}GetAssignmentByDate/GetAssignmentByDate";
  static String notificationUpdateApi = "${baseUrl}NotificationUpdate/NotificationUpdate";
  static String getAssignmentByIdApi = "${baseUrl}GetAssignmentById/GetAssignmentById";
  static String getAssignmentByDatesApi = "${baseUrl}GetAssignmentFromDatetoTodate/GetAssignmentFromDatetoTodate";
  static String getCircularByIdApi = "${baseUrl}GetCircularByCircularId/GetCircularByCircularId";
  static String getTeacherSessionApi = "${baseUrl}SessionSearch/SessionSearch";
}
