//
//  LoginView.swift
//  AC238
//
//  Created by Stéphane Rossé on 26.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import Combine
import SwiftUI
import LocalAuthentication

struct LoginView: View {
    
    @State private var password : String = ""
    @Binding var showLogin: Bool
    
    init(_ showLogin: Binding<Bool>) {
        self._showLogin = showLogin
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                SecureField(LocalizedStringKey("Enter a password"), text: $password).onChange(of: password, perform: { value in
                    if value.count == 4 && value == "1235" {
                        self.showLogin = false
                    }
                })
                .padding(EdgeInsets(top: 0.0, leading: 100.0, bottom: 0.0, trailing: 100.0))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            }
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300.0, height: 300.0)
                .padding(EdgeInsets(top: 25.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
            Spacer()
        }
        .onAppear(perform: authenticate)
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "You want to see your images."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        self.showLogin = false
                    } else {
                        // there was a problem
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(.constant(true))
    }
}

