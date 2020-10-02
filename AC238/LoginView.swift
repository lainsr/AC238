//
//  LoginView.swift
//  AC238
//
//  Created by Stéphane Rossé on 26.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import Combine
import SwiftUI

struct LoginView: View {
    
    @State private var password : String = ""
    @Binding var showLogin: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                SecureField(LocalizedStringKey("Enter a password"), text: $password).onChange(of: password, perform: { value in
                    if value.count == 4 && value == "1235" {
                        self.showLogin = false
                    }
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            }
            Spacer()
        }
    }
    
    init(_ showLogin: Binding<Bool>) {
        self._showLogin = showLogin
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(.constant(true))
    }
}

