//
//  ContentView.swift
//  AC238
//
//  Created by Stéphane Rossé on 11.03.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    
    let file: ACFile
    let path: String
    
    @State private var selection = 0
    @State private var showModal = false
  
    var body: some View {
        ZStack {
            GeometryReader { g in
                self.image(rect: g.size)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .edgesIgnoringSafeArea(.horizontal)
                    .frame(width: g.size.width, height: g.size.height, alignment: .center)
            }
            VStack {
                Spacer()
                Text(file.name)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showModal) {
            FileInformationsModalView(showModal: self.$showModal, file: self.file, path: self.path)
        }
        .onTapGesture {
            self.showModal.toggle()
        }
    }
    
    func image(rect size:CGSize) -> Image {
        if !file.symbol.isEmpty {
            return Image(systemName: file.symbol)
        } else if !file.thumbnailName.isEmpty {
            let thumbnail = file.thumbnail
            let image = ImageScaler.scale(thumbnail, toSize: CGSize(width:size.width, height:size.height), transformed:Int(0), oriented:UIDeviceOrientation.portrait)
            return Image(uiImage: image)
        }
        return Image(systemName: "doc")
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(file: contentData[0], path: "")
    }
}
