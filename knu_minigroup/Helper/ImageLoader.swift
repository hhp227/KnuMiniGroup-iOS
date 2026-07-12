//
//  ImageLoader.swift
//  knu_minigroup
//
//  URL 이미지 로딩 + 메모리 캐시 (Android의 Glide 대응 최소 구현)
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
    }

    func load(_ urlString: String?, into imageView: UIImageView, placeholder: UIImage? = nil) {
        imageView.image = placeholder
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        if let cached = cache.object(forKey: urlString as NSString) {
            imageView.image = cached
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            self?.cache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                imageView?.image = image
            }
        }.resume()
    }
}

extension UIImageView {
    func loadImage(_ urlString: String?, placeholder: UIImage? = nil) {
        ImageLoader.shared.load(urlString, into: self, placeholder: placeholder)
    }
}
