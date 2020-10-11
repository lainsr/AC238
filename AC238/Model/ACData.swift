//
//  ACData.swift
//  AC238
//
//  Created by Stéphane Rossé on 19.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI

let contentData = [ ACFile(id: 1, name: "Orange", path: "",  directory: false, symbol: "", thumbnailName: "image_carre"),
                    ACFile(id: 2, name: "Maison", path: "", directory: false, symbol: "", thumbnailName: "image_carre_300"),
                    ACFile(id: 3, name: "Architecture", path: "", directory: false, symbol: "folder", thumbnailName: "")]


final class ImageStore {
    typealias _ImageDictionary = [String: CGImage]
    fileprivate var images: _ImageDictionary = [:]

    fileprivate static var scale = 1
    
    static var shared = ImageStore()
    
    func image(name: String, path directory: String) -> UIImage {
        let index = _guaranteeImage(name: name, path: directory)
        
        return UIImage(cgImage: images.values[index])
    }

    static func loadImage(name: String, path directory: String) -> CGImage {
        let url = loadImageUrl(name: name, path: directory)
        guard
            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            fatalError("Couldn't load image \(name).jpg from main bundle.")
        }
        return image
    }
    
    static func loadImageUrl(name: String, path directory: String) -> URL {
        let imageUrl: URL
        if name.hasSuffix(".jpg") || name.hasSuffix(".jpeg") || name.hasSuffix(".png") {
            let filePath = directory + "/" + name
            imageUrl = URL(fileURLWithPath: filePath)
        } else {
            imageUrl = Bundle.main.url(forResource: name, withExtension: "jpg")!
        }
        return imageUrl
    }
    
    fileprivate func _guaranteeImage(name: String, path directory: String) -> _ImageDictionary.Index {
        let key = name + "|" + directory;
        
        if let index = images.index(forKey: key) { return index }
        
        images[key] = ImageStore.loadImage(name: name, path: directory)
        return images.index(forKey: key)!
    }
}
