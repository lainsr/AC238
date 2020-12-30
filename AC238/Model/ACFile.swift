//
//  ACFile.swift
//  AC238
//
//  Created by Stéphane Rossé on 19.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//


import SwiftUI
import CoreLocation

struct ACFile : Hashable, Codable, Identifiable {
    
    var id: Int
    var name: String
    var path: String
    var directory: Bool
    var symbol: String
    var thumbnailName: String
    
    func isVideo() -> Bool {
        return ACFile.hasVideoSuffix(filename: name)
    }

    func isImage() -> Bool {
        return ACFile.hasImageSuffix(filename: name)
    }
    
    func suffix() -> String {
        let filename = name
        let indexSuffix = filename.lastIndex(of: ".") ?? filename.endIndex
        let suffix = String(filename[indexSuffix...])
        return String(suffix.dropFirst())
    }
    
    func size() -> String {
        let imageUrl = ImageStore.loadImageUrl(name: name, path: path)
        var size = "0 MB"
        do {
            let resources = try imageUrl.resourceValues(forKeys:[.fileSizeKey])
            let fileSize = resources.fileSize!
            size = convertToFileString(with: fileSize)
        } catch {
           print("Error")
        }
        return size
    }
    
    func convertToFileString(with size: Int) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
    static func hasImageSuffix(filename: String) -> Bool {
        let lowerName = filename.lowercased()
        return lowerName.hasSuffix(".jpg") || lowerName.hasSuffix(".jpeg") || lowerName.hasSuffix(".png")
    }
    
    static func hasVideoSuffix(filename: String) -> Bool {
        let lowerName = filename.lowercased()
        return lowerName.hasSuffix(".mp4") || lowerName.hasSuffix(".m4v") || lowerName.hasSuffix(".mov")
    }
}

extension ACFile {
    
    var thumbnail: UIImage {
        if !symbol.isEmpty {
            return UIImage()
        } else if !thumbnailName.isEmpty {
            return ImageStore.shared.image(name: thumbnailName, path: path)
        } else {
            return UIImage()
        }
    }
}


