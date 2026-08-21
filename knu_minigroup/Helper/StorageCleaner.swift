//
//  StorageCleaner.swift
//  knu_minigroup
//
//  Android helper/StorageCleaner.java 대응
//

import FirebaseStorage
import Foundation

/// 참조를 잃은 Firebase Storage 이미지를 지운다.
///
/// 게시글 수정/삭제, 그룹 커버 교체/그룹 삭제는 RTDB에서 URL만 빼거나 덮어쓰기 때문에
/// 그대로 두면 Storage에 고아 파일이 쌓인다. 정리 규칙은 전부 여기에 모아둔다.
///
/// - Storage 주소가 아닌 URL(LMS 시절 이미지 등)은 조용히 건너뛴다.
/// - 삭제 실패는 로그만 남긴다 — 사용자의 수정/삭제 동작까지 실패시키지 않는다.
/// - 호출은 반드시 **RTDB 반영이 성공한 뒤에** — 순서가 뒤집히면 갱신 실패 시 파일만 사라진다.
enum StorageCleaner {
    /// 갱신 전후 목록을 비교해 빠진 이미지만 지운다. (게시글 수정)
    static func deleteRemoved(oldUrls: [String]?, newUrls: [String]?) {
        guard let oldUrls = oldUrls, !oldUrls.isEmpty else {
            return
        }
        let retained = Set(newUrls ?? [])

        delete(oldUrls.filter { !retained.contains($0) })
    }

    static func delete(_ urls: [String]?) {
        urls?.forEach { delete($0) }
    }

    static func delete(_ url: String?) {
        guard let storageReference = reference(for: url) else {
            return
        }

        storageReference.delete { error in
            guard let error = error else {
                return
            }
            if (error as NSError).code == StorageErrorCode.objectNotFound.rawValue {
                return // 이미 지워진 파일 - 정상으로 본다
            }
            print("이미지 삭제 실패: \(url ?? "") - \(error.localizedDescription)")
        }
    }

    /// 다운로드 URL을 Storage 참조로 바꾼다.
    /// `reference(forURL:)`은 우리 버킷 주소가 아니면 ObjC 예외로 앱을 죽이므로 반드시 먼저 걸러야 한다.
    private static func reference(for url: String?) -> StorageReference? {
        guard let url = url, !url.isEmpty else {
            return nil
        }
        let bucket = Storage.storage().reference().bucket

        guard !bucket.isEmpty,
              url.hasPrefix("gs://\(bucket)/") || url.contains("/v0/b/\(bucket)/o/") else {
            return nil // LMS 시절 URL 등 - 지울 것이 없다
        }
        return Storage.storage().reference(forURL: url)
    }
}
