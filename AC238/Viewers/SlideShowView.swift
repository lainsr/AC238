//
//  SlideShowView.swift
//  AC238
//
//  Created by Stéphane Rossé on 04.10.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct SlideShowView: View {
    
    @State private var showScrollingView = true
    
    let contentArray: [ACFile]
    let directoryPath: String
    @State private var currentIndex: Int = 0
    @State var contentFile: ACFile
    
    init(contentArray: [ACFile], directoryPath: String) {
        var images = [ACFile]()
        for content in contentArray {
            if content.isImage() {
                images.append(content)
            }
        }
        self.contentArray = images
        self.contentFile = images.first!
        self.directoryPath = directoryPath
    }
    
    var body: some View {
        ContentSwipeView(contentArray: self.contentArray, path: self.directoryPath, start: self.contentFile, slide: true)
    }
}

/*
struct SlideShowView_Previews: PreviewProvider {
    static var previews: some View {
        SlideShowView()
    }
}
*/
