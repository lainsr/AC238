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
    
    @Binding var showLogin: Bool
    
    @ObservedObject var viewModel: ContentViewModel

    @State private var focused: [Bool] = [true, false, false, false]
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                SecureFieldTyped(returnVal: .next, tag: 0, text: self.$viewModel.password1, isfocusAble: self.$focused)
                    .frame(width: 40.0, height: 40.0, alignment: .center)
                SecureFieldTyped(returnVal: .next, tag: 1, text: self.$viewModel.password2, isfocusAble: self.$focused)
                    .frame(width: 40.0, height: 40.0, alignment: .center)
                SecureFieldTyped(returnVal: .next, tag: 2, text: self.$viewModel.password3, isfocusAble: self.$focused)
                    .frame(width: 40.0, height: 40.0, alignment: .center)
                SecureFieldTyped(returnVal: .done, tag: 3, text: self.$viewModel.password4, isfocusAble: self.$focused)
                    .frame(width: 40.0, height: 40.0, alignment: .center)
                    
            }
            Spacer()
        }
    }
    
    init(_ showLogin: Binding<Bool>) {
        self._showLogin = showLogin
        viewModel = ContentViewModel(showLogin)
    }

    class ContentViewModel: ObservableObject {
        @Binding var showLogin: Bool
        
        @Published var password1: String = "" {
            didSet {
                checkIfPasswordMatch()
            }
        }
        @Published var password2: String = "" {
            didSet {
                checkIfPasswordMatch()
            }
        }
        @Published var password3: String = "" {
            didSet {
                checkIfPasswordMatch()
            }
        }
        @Published var password4: String = "" {
            didSet {
                checkIfPasswordMatch()
            }
        }
        @Published var enteredTextValue: String = "" {
            didSet {
                checkIfPasswordMatch()
            }
        }
        
        init(_ showLogin: Binding<Bool>) {
            self._showLogin = showLogin
        }

        func checkIfPasswordMatch() {
            let password = password1 + password2 + password3 + password4;
            if password.count == 4 && password == "1235" {
                self.showLogin = false
            }
        }
    }
}

struct SecureFieldTyped: UIViewRepresentable {
    let returnVal: UIReturnKeyType
    let tag: Int
    @Binding var text: String
    @Binding var isfocusAble: [Bool]

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = .numberPad
        textField.returnKeyType = self.returnVal
        textField.tag = self.tag
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 20.0, weight: .bold)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if uiView.window != nil {
            if isfocusAble[tag] {
                if !uiView.isFirstResponder {
                    uiView.becomeFirstResponder()
                }
            } else {
                uiView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SecureFieldTyped

        init(_ textField: SecureFieldTyped) {
            self.parent = textField
        }

        func updatefocus(textfield: UITextField) {
            textfield.becomeFirstResponder()
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
            parent.text = string
            if parent.tag == 0 {
                parent.isfocusAble = [false, true, false, false]
            } else if parent.tag == 1 {
                parent.isfocusAble = [false, false, true, false]
            } else if parent.tag == 2 {
                parent.isfocusAble = [false, false, false, true]
            } else if parent.tag == 3 {
                parent.isfocusAble = [false, false, false, false]
            }
            return true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(.constant(true))
    }
}

