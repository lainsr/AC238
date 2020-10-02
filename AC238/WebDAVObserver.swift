//
//  WebDAVObserver.swift
//  AC238
//
//  Created by Stéphane Rossé on 02.10.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import Foundation

class WebDAVObserver: ObservableObject {
    
    @Published var lastAdditions : [String] = []
    @Published var lastRemovals : [String] = []
    
}


