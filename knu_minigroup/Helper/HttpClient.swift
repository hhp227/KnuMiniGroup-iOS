//
//  HttpClient.swift
//  knu_minigroup
//
//  Android의 Volley(StringRequest) 대응 — URLSession 기반. 콜백은 메인 큐에서 호출된다.
//

import Foundation

enum HttpClient {
    static func request(_ urlString: String,
                        method: String = "GET",
                        headers: [String: String] = [:],
                        formParams: [String: String]? = nil,
                        completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(AppError(message: "잘못된 URL: \(urlString)")))
            }
            return
        }
        var request = URLRequest(url: url)

        request.httpMethod = method
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        if let formParams = formParams {
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

            request.httpBody = encodeParams(formParams).data(using: .utf8)
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(AppError(message: "응답이 비어있습니다.")))
                    return
                }
                completion(.success(decode(data)))
            }
        }.resume()
    }

    // UTF-8 우선, 실패시 EUC-KR로 디코딩 (학교 서버 대응)
    private static func decode(_ data: Data) -> String {
        if let utf8 = String(data: data, encoding: .utf8) {
            return utf8
        }
        let eucKr = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))

        return String(data: data, encoding: String.Encoding(rawValue: eucKr)) ?? ""
    }

    private static func encodeParams(_ params: [String: String]) -> String {
        var allowed = CharacterSet.alphanumerics

        allowed.insert(charactersIn: "-._*")
        return params.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value

            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
    }
}
