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
    
    let file: ACFile
    let path: String
    
    var body: some View {
        VStack {
            Text(file.name)
                .padding()
            Spacer()
        }
        .onTapGesture(perform: {
            self.showModal.toggle()
        })
    }
}
