//
//  FileInformationsModalView.swift
//  AC238
//
//  Created by Stéphane Rossé on 26.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct FileInformationsModalView: View {
    
    @Binding var showModal: Bool
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let file: ACFile
    let path: String
    
    var body: some View {
        HStack {
            if sizeClass == .compact {
                VStack(alignment: .leading) {
                    if !file.thumbnailName.isEmpty {
                        self.image(rect: CGSize(width: 300, height: 300))
                            .cornerRadius(20)
                            .padding(EdgeInsets(top: 20, leading: 5, bottom: 5, trailing: 5))
                    }
                    FileMetadataView(file:file, path:path)
                }
            } else {
                HStack(alignment: .center) {
                    if !file.thumbnailName.isEmpty {
                        self.image(rect: CGSize(width: 300, height: 300))
                            .cornerRadius(20)
                            .padding(EdgeInsets(top: 20, leading: 5, bottom: 5, trailing: 5))
                    }
                    FileMetadataView(file:file, path:path)
                }
            }
        }
        .onTapGesture(perform: {
            self.showModal.toggle()
        })
    }
    
    func image(rect size:CGSize) -> Image {
        let thumbnail = file.thumbnail
        let image = ImageScaler.scale(thumbnail, toSize: CGSize(width:size.width, height:size.height), transformed:Int(0), oriented:UIDeviceOrientation.portrait)
        return Image(uiImage: image)
    }
}
