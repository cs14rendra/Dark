//
//  ImageCache.swift
//  Dark
//
//  Created by surendra kumar on 11/5/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation

class ImageCache {
    private var images = [URL:UIImage]()
    private static let _sharedInstanse = ImageCache()
    static var sharedInstanse : ImageCache{
        return _sharedInstanse
    }
    
    init() {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: .main) { [weak self] notification in
            self?.images.removeAll(keepingCapacity: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func loadimage(atURL url : URL, completion : @escaping (UIImage?)->()){
        if let image = ImageCache.sharedInstanse.image(forKey: url){
            completion(image)
        }else{
            ImageCache.sharedInstanse.loadImageFromServer(atURL: url, completion: { image in
                if let img = image {
                    self.set(image: img, forKey: url)
                }
                completion(image)
            })
        }
    }
    
    private func loadImageFromServer(atURL url : URL, completion : @escaping (UIImage?) -> ()) {
       let task =  URLSession.shared.dataTask(with: url) { data, response, error in
            guard let imageData = data ,let img = UIImage(data: imageData) else{
                completion(nil)
                return
            }
           completion(img)
        }
        task.resume()
    }
    
}

extension ImageCache{
    private func set(image : UIImage, forKey key : URL){
        images[key] = image
    }
    private func image(forKey key : URL) -> UIImage?{
        return images[key]
    }
}
