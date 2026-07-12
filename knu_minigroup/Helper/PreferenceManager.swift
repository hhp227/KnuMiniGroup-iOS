//
//  PreferenceManager.swift
//  knu_minigroup
//
//  Android의 helper.PreferenceManager(SharedPreferences) 대응 — UserDefaults 기반
//

import Foundation

class PreferenceManager {
    static let shared = PreferenceManager()

    private static let KEY_USER_ID = "usr_id"
    private static let KEY_USER_PASSWORD = "usr_pwd"
    private static let KEY_USER_NAME = "usr_nm"
    private static let KEY_USER_DEPT_NAME = "usr_dept_nm"
    private static let KEY_USER_NUMBER = "usr_stu_id"
    private static let KEY_USER_GRADE = "usr_grade"
    private static let KEY_USER_EMAIL = "usr_mail"
    private static let KEY_USER_UNIQUE_ID = "usr_uid"
    private static let KEY_USER_IP = "usr_ip"
    private static let KEY_USER_CAMPUS = "usr_campus"
    private static let KEY_HP = "usr_hp"

    private let defaults = UserDefaults.standard

    private init() {
    }

    func storeUser(_ user: User) {
        defaults.set(user.userId, forKey: PreferenceManager.KEY_USER_ID)
        defaults.set(user.password, forKey: PreferenceManager.KEY_USER_PASSWORD)
        defaults.set(user.name, forKey: PreferenceManager.KEY_USER_NAME)
        defaults.set(user.department, forKey: PreferenceManager.KEY_USER_DEPT_NAME)
        defaults.set(user.number, forKey: PreferenceManager.KEY_USER_NUMBER)
        defaults.set(user.grade, forKey: PreferenceManager.KEY_USER_GRADE)
        defaults.set(user.email, forKey: PreferenceManager.KEY_USER_EMAIL)
        defaults.set(user.uid, forKey: PreferenceManager.KEY_USER_UNIQUE_ID)
        defaults.set(user.userIp, forKey: PreferenceManager.KEY_USER_IP)
        defaults.set(user.campus, forKey: PreferenceManager.KEY_USER_CAMPUS)
        defaults.set(user.phoneNumber, forKey: PreferenceManager.KEY_HP)
    }

    var user: User? {
        guard let userId = defaults.string(forKey: PreferenceManager.KEY_USER_ID) else {
            return nil
        }
        var user = User()

        user.userId = userId
        user.password = defaults.string(forKey: PreferenceManager.KEY_USER_PASSWORD)
        user.name = defaults.string(forKey: PreferenceManager.KEY_USER_NAME)
        user.department = defaults.string(forKey: PreferenceManager.KEY_USER_DEPT_NAME)
        user.number = defaults.string(forKey: PreferenceManager.KEY_USER_NUMBER)
        user.grade = defaults.string(forKey: PreferenceManager.KEY_USER_GRADE)
        user.email = defaults.string(forKey: PreferenceManager.KEY_USER_EMAIL)
        user.uid = defaults.string(forKey: PreferenceManager.KEY_USER_UNIQUE_ID)
        user.userIp = defaults.string(forKey: PreferenceManager.KEY_USER_IP)
        user.campus = defaults.string(forKey: PreferenceManager.KEY_USER_CAMPUS)
        user.phoneNumber = defaults.string(forKey: PreferenceManager.KEY_HP)
        return user
    }

    func clear() {
        [PreferenceManager.KEY_USER_ID, PreferenceManager.KEY_USER_PASSWORD, PreferenceManager.KEY_USER_NAME,
         PreferenceManager.KEY_USER_DEPT_NAME, PreferenceManager.KEY_USER_NUMBER, PreferenceManager.KEY_USER_GRADE,
         PreferenceManager.KEY_USER_EMAIL, PreferenceManager.KEY_USER_UNIQUE_ID, PreferenceManager.KEY_USER_IP,
         PreferenceManager.KEY_USER_CAMPUS, PreferenceManager.KEY_HP].forEach(defaults.removeObject(forKey:))
    }
}
