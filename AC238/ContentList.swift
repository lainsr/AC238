//
//  ContentList.swift
//  AC238
//
//  Created by Stéphane Rossé on 19.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct ContentList: View {
    
    @State private var showScrollingView = true
    @EnvironmentObject var davObserver: WebDAVObserver
    
    let contentName: String
    let directoryPath: String
    @State var contentArray: [ACFile]
    
    var body: some View {
        List(contentArray, id: \.id) { contentFile in
            NavigationLink(destination: ContentSwitchView(contentArray: self.contentArray, directoryPath: self.directoryPath, file: contentFile, showScrollingView: $showScrollingView)) {
                ContentRow(file: contentFile).onAppear() {
                    if(self.showScrollingView) {
                        self.showScrollingView = false
                    }
                }
                .id("row-" + contentFile.name)
            }
            .id("link-" + contentFile.name)
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text(contentName))
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing: NavigationLink(destination: SlideShowView(contentArray: contentArray)) {
            Image(systemName: "play.circle")
        })
        .onChange(of: davObserver.lastAdditions, perform: { value in
            processDAVAdditions(additions: value)
        })
        .onChange(of: davObserver.lastRemovals, perform: { value in
            processDAVRemovals(removals: value)
        })
    }
    
    func processDAVRemovals(removals: [String]) {
        if let lastRemoval = removals.last {
            let fileName = URL(fileURLWithPath: lastRemoval).lastPathComponent
            let lastDirectory = URL(fileURLWithPath: lastRemoval).deletingLastPathComponent()
                .absoluteString
                .replacingOccurrences(of: "//", with: "/")
            let directoryAbsolutePath = URL(fileURLWithPath: directoryPath)
                .absoluteString
                .replacingOccurrences(of: "//", with: "/")
            if(lastDirectory == directoryAbsolutePath) {
                for content in contentArray {
                    if(content.name == fileName) {
                        if let contentIndex = contentArray.firstIndex(of: content) {
                            contentArray.remove(at: contentIndex)
                        }
                        break
                    }
                }
            }
        }
    }
    
    func processDAVAdditions(additions: [String]) {
        if let lastAddition = additions.last {
            let fileName = URL(fileURLWithPath: lastAddition).lastPathComponent
            let lastDirectory = URL(fileURLWithPath: lastAddition).deletingLastPathComponent().absoluteString
                .replacingOccurrences(of: "//", with: "/")
            let directoryAbsolutePath = URL(fileURLWithPath: directoryPath).absoluteString
                .replacingOccurrences(of: "//", with: "/")
            if(lastDirectory == directoryAbsolutePath) {
                var alreadyInList = false
                for content in contentArray {
                    if(content.name == fileName) {
                        alreadyInList = true
                    }
                }
                
                if !alreadyInList {
                    let count = contentArray.count
                    let acFile = SceneDelegate.file(id: count, fileName: fileName, directory: directoryPath)
                    var acFiles = contentArray
                    acFiles.append(acFile)
                    acFiles.sort() {
                        $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    }
                    if let index = acFiles.firstIndex(of: acFile) {
                        contentArray.insert(acFile, at: index)
                    } else {
                        contentArray.append(acFile)
                    }
                }
            }
        }
    }
    
}

struct ContentList_Previews: PreviewProvider {
    static var previews: some View {
        ContentList(contentName: "Anime", directoryPath: "",
                    contentArray: contentData)
    }
}
