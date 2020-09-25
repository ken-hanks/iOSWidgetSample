//
//  ImageHelper.swift
//  SingleNewsExtension
//
//  Created by KANG HAN on 2020/9/25.
//

import Foundation
import UIKit

struct ImageHelper {
    
    static func downloadImage(url: URL, completion: @escaping(Result<UIImage, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            let image: UIImage? = UIImage(data: data!)
            completion(.success(image!))
        }
        task.resume()
    }
}
