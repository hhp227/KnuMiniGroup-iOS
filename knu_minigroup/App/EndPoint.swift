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
    static let LOGIN = "https://knusso.knu.ac.kr/authentication/idpw/loginProcess"
    static let GROUP_LIST = BASE_URL + "/ilos/m/community/share_group_list.acl"
    static let MODIFY_GROUP = BASE_URL + "/ilos/community/share_group_modify.acl"
    static let UPDATE_GROUP = BASE_URL + "/ilos/community/share_group_update.acl"
    static let GROUP_MEMBER_LIST = BASE_URL + "/ilos/community/share_group_member_list.acl"
    static let GROUP_IMAGE_UPDATE = BASE_URL + "/ilos/community/share_group_image_update.acl"
    static let IMAGE_UPLOAD = BASE_URL + "/ilos/tinymce/file_upload_pop.acl"
    static let USER_IMAGE = BASE_URL + "/ilos/mp/user_image_view.acl?id={UID}&ext=.jpg"
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
