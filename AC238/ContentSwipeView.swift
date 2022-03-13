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
    
    @State private var slide: Bool
    let fullContentArray: [ACFile]
    let path: String
    let spacing: CGFloat = 10
    var firstFile: ACFile
    @State var partialContentArray: [ACFile] = [ACFile]()
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    init(contentArray files: [ACFile], path: String, start firstFile: ACFile, slide: Bool) {
        self.slide = slide
        self.path = path
        self.fullContentArray = files.filter{$0.isImage()}
        self.firstFile = firstFile
        if !self.slide {
            timer.upstream.connect().cancel()
        }
    }
    
    var body: some View {
        GeometryReader { g in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(self.partialContentArray) { contentFile in
                        ImageView(file: contentFile, path: self.path)
                            .frame(width: g.size.width, height: g.size.height, alignment: .topLeading)
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
                        if -value.predictedEndTranslation.width > g.size.width / 2, self.index < self.partialContentArray.count - 1 {
                            self.index += 1
                        } else if value.predictedEndTranslation.width > g.size.width / 2, self.index > 0 {
                            self.index -= 1
                        }
                        self.filename = self.partialContentArray[self.index].name
                        print("Swip width: ", g.size.width, " x ", g.size.height)
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.offset = -(g.size.width + self.spacing) * CGFloat(self.index)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            reflowPartialContentArray(gWidth: g.size.width)
                        }
                    })
            )
            .onAppear() {
                let fileIndex = fullContentArray.firstIndex(of: firstFile) ?? 0
                var startIndex = fileIndex - 2
                if startIndex < 0 {
                    startIndex = 0
                }
                var endIndex = fileIndex + 2
                if endIndex > fullContentArray.count {
                    endIndex = fullContentArray.count
                }
                
                for n in startIndex..<endIndex {
                    self.partialContentArray.append(fullContentArray[n])
                }
                
                let partialIndex = self.partialContentArray.firstIndex(of: firstFile) ?? 0
                self.index = partialIndex
                self.filename = self.firstFile.name
                var pageWidth:CGFloat
                if g.size.width == 0 {
                    pageWidth = UIScreen.main.bounds.width
                } else {
                    pageWidth = g.size.width
                }
                self.offset =  -(pageWidth + self.spacing) * CGFloat(self.index)
            }.onReceive(timer, perform: { _ in
                if self.slide {
                    slideNext(gWidth: g.size.width)
                }
            }).onReceive(orientationChanged) {_ in
                
                // Doesn't work
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.offset = -(g.size.width + self.spacing) * CGFloat(self.index)
                    }
                }
            }.onDisappear() {
                self.slide = false
            }
        }
    }
    
    private func slideNext(gWidth: CGFloat) {
        self.index += 1
        if self.index >= self.partialContentArray.count {
            self.index = 0
        }
        self.filename = self.partialContentArray[self.index].name
        
        withAnimation(.easeOut(duration: 0.3)) {
            self.offset = -(gWidth + self.spacing) * CGFloat(self.index)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            reflowPartialContentArray(gWidth: gWidth)
        }
    }
    
    private func reflowPartialContentArray(gWidth: CGFloat) {
        if self.index + 2 >= self.partialContentArray.count {
            if let lastItem = self.partialContentArray.last {
                if let nextIndex = fullContentArray.firstIndex(of: lastItem) {
                    if nextIndex + 1 < fullContentArray.count {
                        self.partialContentArray.append(fullContentArray[nextIndex + 1])
                    }
                }
            }
        }
        
        if self.index < 2 {
            if let firstItem = self.partialContentArray.first {
                if let nextIndex = fullContentArray.firstIndex(of: firstItem) {
                    if nextIndex - 1 >= 0 {
                        self.partialContentArray.insert(fullContentArray[nextIndex - 1], at: 0)
                        self.index += 1
                        self.offset = -(gWidth + self.spacing) * CGFloat(self.index)
                    }
                }
            }
        } else if self.index > 3 {
            self.partialContentArray.removeFirst()
            self.index -= 1
            self.offset = -(gWidth + self.spacing) * CGFloat(self.index)
        } else if self.partialContentArray.count > 7 {
            let numToRemove = self.partialContentArray.count - 7
            self.partialContentArray.removeLast(numToRemove)
        }
    }
}

/*
struct ContentSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentSwipeView(contentArray: contentData, path: "", start: 0)
    }
}
*/
