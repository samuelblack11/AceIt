//
//  CustomDataTypes.swift
//  Inflated
//
//  Created by Sam Black on 8/20/23.
//

import Foundation
import SwiftUI
import CoreData
import UIKit

protocol ListItemProtocol {
    var name: String? { get }
    var priceCurrent: NSDecimalNumber? { get }
    var price1Ago: NSDecimalNumber? { get }
    var price2Ago: NSDecimalNumber? { get }
    var price3Ago: NSDecimalNumber? { get }
    var vendor: String? { get }
    var region: String? { get }
    var analysis: String? { get }
}

struct NielsenDataPlaceholder: ListItemProtocol {
    var name: String?
    var priceCurrent: NSDecimalNumber?
    var price1Ago: NSDecimalNumber?
    var price2Ago: NSDecimalNumber?
    var price3Ago: NSDecimalNumber?
    var vendor: String?
    var region: String?
    var analysis: String?
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

enum TitleContent {
    case text(String)
    case image(String)
}

struct CustomNavigationBar: View {
    var onBackButtonTap: (() -> Void)?
    var titleContent: TitleContent
    var rightButtonAction: (() -> Void)?
    var showBackButton: Bool = true
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        HStack {
            if showBackButton {
                Button(action: onBackButtonTap ?? {}) {
                    HStack {
                        Image(systemName: "chevron.left").foregroundColor(.blue)
                        Text("Back")
                            .foregroundColor(.blue)
                            .font(Font.custom("Helvetica-Bold", size: 16))
                    }
                }
                .padding(.leading, 10)
            } else {
                Spacer().frame(width: 80) // Adjust width as needed to balance out spacing if there's no back button.
            }

            Spacer()

            switch titleContent {
            case .text(let title):
                Text(title)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .font(.custom("Helvetica-Bold", size: 20))
            case .image(let imageName):
                Image(imageName)
                    .resizable()
                    .colorMultiply(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: UIScreen.screenWidth/8, maxHeight: UIScreen.screenHeight/15, alignment: .center)
            }

            Spacer()

            if let rightAction = rightButtonAction {
                Button(action: rightAction) {
                    Image(systemName: "menucard.fill").foregroundColor(.blue)
                    Text("Menu")
                        .font(Font.custom("Papyrus", size: 16))
                }
                .padding(.trailing, 10)
            } else {
                Spacer().frame(width: 80) // Adjust width as needed to balance out spacing if there's no right content.
            }
        }
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onSubmit: (() -> Void)?  // Added this closure

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SearchBar

        init(_ parent: SearchBar) {
            self.parent = parent
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            parent.onSubmit?()  // Execute the closure when the search button is clicked
        }
    }
}

