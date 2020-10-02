//
//  RootContentList.swift
//  AC238
//
//  Created by Stéphane Rossé on 25.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct RootContentList: View {
    
    @State private var showLogin = true
    
    let contentName: String
    let directoryPath: String
    let contentArray: [ACFile]
    let davObserver: WebDAVObserver
    
    var body: some View {
        NavigationView {
            ContentList(contentName: contentName, directoryPath: directoryPath, contentArray: contentArray)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(davObserver)
        .sheet(isPresented: $showLogin) {
            LoginView(self.$showLogin)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.showLogin = true
        }
    }
    
    func presentLogin() {
        showLogin = true
    }
}

struct RootContentList_Previews: PreviewProvider {
    static var previews: some View {
        RootContentList(contentName: "Anime", directoryPath: "", contentArray: contentData, davObserver: WebDAVObserver())
    }
}
