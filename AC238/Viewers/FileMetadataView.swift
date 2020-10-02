//
//  FileMetadataView.swift
//  AC238
//
//  Created by Stéphane Rossé on 02.10.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct FileMetadataView: View {
    
    private let insets = EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0)
    
    let file: ACFile
    let path: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey("Filename"))
                .bold()
                .padding(insets)
            Text(file.name)
                .italic()
            Text(LocalizedStringKey("Filesize"))
                .bold()
                .padding(insets)
            Text(file.size())
                .italic()
            Text(LocalizedStringKey("Filetype"))
                .bold()
                .padding(insets)
            Text(file.suffix())
                .italic()
        }
    }
}

struct FileMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        FileMetadataView(file: ACFile(id: 1, name: "Maison", path: "", directory: false, symbol: "", thumbnailName: "image_carre_300"), path: "")
    }
}
