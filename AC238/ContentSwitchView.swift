//
//  ContentSwitchView.swift
//  AC238
//
//  Created by Stéphane Rossé on 25.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct ContentSwitchView: View {
    
    let contentArray: [ACFile]
    let currentIndex: Int
    let directoryPath: String
    let file: ACFile
    
    @Binding var showScrollingView : Bool
    
    var body: some View {
        VStack {
            if file.directory {
                ContentList(contentName: file.name, directoryPath: childDirectoryPath(), contentArray: childContentArray())
            } else {
                ContentSwipeView(contentArray: contentArray, path: directoryPath, start: currentIndex)
            }
        }
        .opacity(showScrollingView ? 1.0 : 0.0)
        .onAppear() {
            self.showScrollingView = true
        }
    }
    
    func childDirectoryPath() -> String {
        let path = directoryPath + "/" + file.name;
        return path
    }
    
    func childContentArray() -> [ACFile] {
        let path = childDirectoryPath();
        return SceneDelegate.listFiles(filesOf: path)
    }
}
