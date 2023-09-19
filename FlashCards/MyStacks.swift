//
//  MyStacks.swift
//  FlashCards
//
//  Created by Sam Black on 9/13/23.
//

import Foundation
import SwiftUI

struct MyStacks: View {
    // This is just a sample data for the grid.
    // In your actual implementation, you'd replace this with data fetched from Core Data.
    @Environment(\.managedObjectContext) private var viewContext
    @State private var distinctCategories: [String] = []
    @EnvironmentObject var appState: AppState
    @State private var showFlashCard: Bool = false
    @State private var selectedCategory: String?
    @State private var chosenStack: IdentifiableFlashCards?
    @EnvironmentObject var alertVars: AlertVars
    @State private var stackToDelete: String = ""

    var body: some View {
        VStack {
            CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .mainMenu}, titleContent: .text("My Stacks"))
            Group {
                if distinctCategories.isEmpty {
                    Text("You haven't created any stacks yet")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    let gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
                    ScrollView {
                        LazyVGrid(columns: gridLayout, spacing: 20) {
                            ForEach(distinctCategories, id: \.self) { stack in
                                VStack {
                                    Image(systemName: "square.stack")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .background(Color.gray)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(radius: 10)
                                        .onTapGesture {
                                            if let validStack = fetchFlashCards(withCategory: stack) {
                                                chosenStack = IdentifiableFlashCards(cards: validStack)
                                            }
                                        }
                                    Text(stack)
                                }
                                .padding()
                                .contextMenu {
                                    Button(action: {
                                        // Present the CardListView (this is already done with tap)
                                    }) {
                                        Label("View Cards", systemImage: "eye.fill")
                                    }
                                    Button(action: {
                                        stackToDelete = stack
                                        alertVars.alertType = .verifyStackDelete
                                        alertVars.activateAlert = true
                                    }) {
                                        Label("Delete Stack", systemImage: "trash.fill")
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                        .sheet(item: $chosenStack) { identifiableStack in
                            FlashCardListView(flashCards: identifiableStack.cards)
                        }
                    }
                }
                Spacer()
            }
            .onAppear {fetchDistinctCategories()}
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {self.deleteCards(forCategory: stackToDelete) { didDelete in fetchAllDistinctCategories()}}))
    }
    
    private func fetchDistinctCategories() {
        let results = fetchAllDistinctCategories()
        self.distinctCategories = Array(results)
    }
    
}

extension MyStacks {
    
    func fetchFlashCards(withCategory category: String) -> [FlashCard]? {
        let fetchRequest = FlashCard.createFetchRequest()
        let predicate = NSPredicate(format: "category1 == %@ OR category2 == %@ OR category3 == %@", category, category, category)
        fetchRequest.predicate = predicate

        do {
            let results = try viewContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }

    func deleteCard(card: FlashCard) {
        viewContext.delete(card)
        do {try viewContext.save()}
        catch {print("Error deleting card: \(error)")}
    }
    
    func deleteCards(forCategory category: String, completion: @escaping (Bool) -> Void) {
        let fetchRequest = FlashCard.createFetchRequest()
        let predicateCategory1 = NSPredicate(format: "category1 == %@ AND category2 == nil AND category3 == nil", category)
        let predicateCategory2 = NSPredicate(format: "category2 == %@ AND category1 == nil AND category3 == nil", category)
        let predicateCategory3 = NSPredicate(format: "category3 == %@ AND category1 == nil AND category2 == nil", category)
        let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicateCategory1, predicateCategory2, predicateCategory3])
        fetchRequest.predicate = combinedPredicate

        do {
            let cardsToDelete = try viewContext.fetch(fetchRequest)
            for card in cardsToDelete {deleteCard(card: card)}
            completion(true) // Indicate successful deletion with `true`
        } catch {
            print("Error fetching cards to delete: \(error)")
            completion(false) // Indicate failure with `false`
        }
    }

    func fetchAllDistinctCategories() -> Set<String> {
        let category1Values = fetchDistinctValuesFor(attribute: "category1")
        let category2Values = fetchDistinctValuesFor(attribute: "category2")
        let category3Values = fetchDistinctValuesFor(attribute: "category3")

        return Set(category1Values + category2Values + category3Values)
    }

    
    func fetchDistinctValuesFor(attribute: String) -> [String] {
        let fetchRequest = FlashCard.createFetchRequest()
        fetchRequest.propertiesToFetch = [attribute]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .managedObjectResultType

        var distinctStrings: [String] = []

        do {
            if let fetchedResults = try viewContext.fetch(fetchRequest) as? [FlashCard] {
                for card in fetchedResults {
                    if let value = card.value(forKey: attribute) as? String, value != "NaN" {
                        distinctStrings.append(value)
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return distinctStrings
    }




}

struct StacksGridView_Previews: PreviewProvider {
    static var previews: some View {
        MyStacks()
    }
}
