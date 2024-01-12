//
//  CustomImageView.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-29.
//

import UIKit

class CustomImageView: UIImageView {
    
    // Retrieve image async from URL
    func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let data = data,
                let newImage = UIImage(data: data)
            else {
                print("Unsuccessful URL Session. Couldn't load image from URL: \(url)")
                return
            }
            
            DispatchQueue.main.async {
                self.image = newImage
            }
        }
        task.resume()
    }
}
