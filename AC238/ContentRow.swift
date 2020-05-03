//
//  ContentRow.swift
//  AC238
//
//  Created by Stéphane Rossé on 19.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct ContentRow: View {
    
    var file: ACFile
    
    var body: some View {
        HStack {
            thumbnail()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50, alignment: .center)
            Text(file.name)
            Spacer()
        }
    }
    
    func thumbnail() -> Image {
        if !file.symbol.isEmpty {
            return Image(systemName: file.symbol)
        } else if !file.thumbnailName.isEmpty {
            let thumbnail = file.thumbnail
            let image = ImageScaler.scale(thumbnail, toSize: CGSize(width:50, height:50), transformed:Int(0), oriented:UIDeviceOrientation.portrait)
            return Image(uiImage: image)
        }
        return Image(systemName: "doc")
    }
}

struct ContentRow_Previews: PreviewProvider {
    static var previews: some View {
        ContentRow(file: ACFile(id: 1, name: "Maison", path: "", directory: false, symbol: "", thumbnailName: "image_carre_300"))
    }
}

