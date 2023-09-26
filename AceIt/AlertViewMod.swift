//
//  AlertViewMod.swift
//  Ace It
//
//  Created by Sam Black on 9/14/23.
//

import Foundation
import SwiftUI

struct AlertViewMod: ViewModifier {
    @Binding var showAlert: Bool
    var activeAlert: ActiveAlert
    var alertDismissAction: (() -> Void)?

    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $showAlert) {
                switch activeAlert {
                case .verifyStackDelete:
                    return Alert(
                        title: Text("Are you sure you want to delete this stack?"),
                        message: Text(""),
                        primaryButton: .default(Text("Yes, delete it"), action: {alertDismissAction?()}),
                        secondaryButton: .default(Text("No, I'll keep it"), action: {})
                    )
                case .stackCreated:
                    return Alert(
                        title: Text("New Category Created"),
                        message: Text("It will be available to use momentarily"),
                        dismissButton: .default(Text("Ok"), action: {alertDismissAction?()})
                    )
            }
        }
    }
}

class AlertVars: ObservableObject {
    static let shared = AlertVars()
    @Published var activateAlert: Bool = false
    @Published var alertType: ActiveAlert = .verifyStackDelete
    private init() {}
    
    var activateAlertBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.activateAlert },
            set: { self.activateAlert = $0 }
        )
    }
    
    
}

extension View {
    func alertView(alertVars: AlertVars) -> some View {
        self.modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
    }
}

enum ActiveAlert {
    case verifyStackDelete, stackCreated
}
