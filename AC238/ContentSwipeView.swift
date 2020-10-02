//
//  ContentSwipeView.swift
//  AC238
//
//  Created by Stéphane Rossé on 25.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct ContentSwipeView: View {
    
    @State private var offset: CGFloat = 0
    @State private var index = 0
    @State private var filename : String = ""
    
    let contentArray: [ACFile]
    let path: String
    let spacing: CGFloat = 10
    var firstIndex: Int
    
    init(contentArray files: [ACFile], path: String, start firstIndex: Int) {
        var filterContentArray = [ACFile]()
        for file in files {
            if !file.directory {
                filterContentArray.append(file)
            }
        }
        self.path = path
        self.contentArray = filterContentArray
        self.firstIndex = filterContentArray.firstIndex(of: files[firstIndex]) ?? 0
    }
    
    var body: some View {
        GeometryReader { g in
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHStack(alignment: .top, spacing: 10) {
                    ForEach(self.contentArray) { contentFile in
                        if contentFile.name.hasSuffix(".mp4") || contentFile.name.hasSuffix(".m4v") {
                            VideoView(file: contentFile, path: self.path)
                                .frame(width: g.size.width, height: g.size.height, alignment: .topLeading)
                        } else {
                            ImageView(file: contentFile, path: self.path)
                                .frame(width: g.size.width, height: g.size.height, alignment: .topLeading)
                        }
                    }
                }
            }
            .content.offset(x: self.offset)
            .navigationBarTitle(Text(filename), displayMode: .inline)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        self.offset = value.translation.width - g.size.width * CGFloat(self.index)
                    })
                    .onEnded({ value in
                        if -value.predictedEndTranslation.width > g.size.width / 2, self.index < self.contentArray.count - 1 {
                            self.index += 1
                        }
                        if value.predictedEndTranslation.width > g.size.width / 2, self.index > 0 {
                            self.index -= 1
                        }
                        self.filename = self.contentArray[self.index].name
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.offset = -(g.size.width + self.spacing) * CGFloat(self.index)
                        }
                    })
            )
            .onAppear() {
                self.index = self.firstIndex
                self.filename = self.contentArray[self.index].name
                var pageWidth:CGFloat
                if g.size.width == 0 {
                    pageWidth = UIScreen.main.bounds.width
                } else {
                    pageWidth = g.size.width
                }
                self.offset =  -(pageWidth + self.spacing) * CGFloat(self.index)
            }
        }
    }
}

struct ContentSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentSwipeView(contentArray: contentData, path: "", start: 0)
    }
}
