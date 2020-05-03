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


