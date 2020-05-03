//
//  ContentList.swift
//  AC238
//
//  Created by Stéphane Rossé on 19.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct ContentList: View {
    
    let contentName: String
    let directoryPath: String
    let contentArray: [ACFile]
    
    var body: some View {
        List(contentArray) { contentFile in
            NavigationLink(destination: ContentSwitchView(contentArray: self.contentArray, currentIndex: contentFile.id, directoryPath: self.directoryPath, file: contentFile)) {
                ContentRow(file: contentFile)
            }
        }
        .navigationBarTitle(Text(contentName))
    }
    
}

struct ContentList_Previews: PreviewProvider {
    static var previews: some View {
        ContentList(contentName: "Anime", directoryPath: "",
                    contentArray: contentData)
    }
}
