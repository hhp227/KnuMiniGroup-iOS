//
//  EndPoint.swift
//  knu_minigroup
//
//  Android의 app.EndPoint 대응
//

import Foundation

enum EndPoint {
    // 경북대 LMS URL (서버 폐쇄 — Android와 동일하게 상수는 유지)
    static let BASE_URL = "https://lms.knu.ac.kr"

    // Firebase Storage 공개 다운로드 URL (GoogleService-Info.plist의 STORAGE_BUCKET과 일치해야 한다)
    static let STORAGE_BASE_URL = "https://firebasestorage.googleapis.com/v0/b/hhp227-ed727.appspot.com/o/"

    // 프로필 이미지 저장 경로. USER_IMAGE가 이 경로를 URL로 조립하므로 둘을 함께 바꿔야 한다.
    static let STORAGE_PROFILE_IMAGE_PATH = "profile_images"
    static let LOGIN = "https://knusso.knu.ac.kr/authentication/idpw/loginProcess"
    static let GROUP_LIST = BASE_URL + "/ilos/m/community/share_group_list.acl"
    static let MODIFY_GROUP = BASE_URL + "/ilos/community/share_group_modify.acl"
    static let UPDATE_GROUP = BASE_URL + "/ilos/community/share_group_update.acl"
    static let GROUP_MEMBER_LIST = BASE_URL + "/ilos/community/share_group_member_list.acl"
    static let GROUP_IMAGE_UPDATE = BASE_URL + "/ilos/community/share_group_image_update.acl"
    static let IMAGE_UPLOAD = BASE_URL + "/ilos/tinymce/file_upload_pop.acl"
    // LMS 서버가 닫혀 프로필 이미지는 Firebase Storage에 uid별 고정 경로로 저장한다.
    // 경로가 uid로 정해지므로 조회 없이 URL을 조립할 수 있다 (Android EndPoint와 동일).
    static let USER_IMAGE = STORAGE_BASE_URL + "profile_images%2F{UID}.jpg?alt=media"
    static let TIMETABLE = BASE_URL + "/ilos/st/main/pop_academic_timetable_form.acl"
    static let GROUP_IMAGE = BASE_URL + "/ilosfiles2/club/photo/{FILE}"
    static let DEFAULT_GROUP_IMAGE = BASE_URL + "/ilos/images/community/share_nophoto.gif"

    // 학교 URL
    static let URL_KNU = "https://www.knu.ac.kr"
    static let URL_SCHEDULE = URL_KNU + "/wbbs/wbbs/user/yearSchedule/xmlResponse.action?schedule.search_date={YEAR-MONTH}"
    static let URL_SHUTTLE = URL_KNU + "/wbbs/wbbs/contents/index.action?menu_url=intro/{SHUTTLE}&menu_idx=27"
    static let URL_KNU_NOTICE = URL_KNU + "/wbbs/wbbs/bbs/btin/list.action?bbs_cde=1&btin.page={PAGE}&popupDeco=false&btin.search_type=&btin.search_text=&menu_idx=67"
    static let URL_KNU_DORM_MEAL = "http://dorm.knu.ac.kr/xml/food.php?get_mode={ID}"
    static let URL_KNU_MEAL = "http://coop.knu.ac.kr/pages/xml_menu.php?get_mode={ID}"
    static let URL_KNULIBRARY_SEAT = "http://seat.knu.ac.kr/smufu-api/pc/{ID}/rooms-at-seat"
}
