//
//  SlideShowView.swift
//  AC238
//
//  Created by Stéphane Rossé on 04.10.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct SlideShowView: View {
    
    let contentArray: [ACFile]
    //@State var currentImage: ACFile
    
    init(contentArray: [ACFile]) {
        var images = [ACFile]()
        for content in contentArray {
            if content.isImage() {
                images.append(content)
            }
        }
        self.contentArray = images
        //self.currentImage = images.first!
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

/*
struct SlideShowView_Previews: PreviewProvider {
    static var previews: some View {
        SlideShowView()
    }
}
*/
