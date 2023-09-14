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

    var body: some View {
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
                                Text(stack)
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .onAppear {fetchDistinctCategories()}
    }
    private func fetchDistinctCategories() {
        if let results = fetchDistinctValues() {
            var allCategories: [String] = []

            // Iterate over each dictionary and add the values to our list
            for result in results {
                allCategories.append(contentsOf: result.values.compactMap { $0 as? String })
            }

            // Filter out "NaN" and duplicates
            self.distinctCategories = Array(Set(allCategories.filter { $0 != "NaN" }))
        }
    }
}


extension MyStacks {
    func loadCards() -> [FlashCard] {
        let request = FlashCard.createFetchRequest()
        //let sort = NSSortDescriptor(key: "date", ascending: false)
        //request.sortDescriptors = [sort]
        var coreProducts: [FlashCard] = []
        do {coreProducts = try viewContext.fetch(request)}
        catch {print("Fetch failed")}
        return coreProducts
    }
    
    func deleteProduct(product: FlashCard) {
        do {viewContext.delete(product);try viewContext.save()}
        catch {}
    }
    
    func deleteAllProducts() {
        let request = FlashCard.createFetchRequest()
        var products: [FlashCard] = []
        do {products = try viewContext.fetch(request); for product in products {deleteProduct(product: product)}}
        catch{}
    }
    
    func fetchDistinctValues() -> [[String: Any]] {
        let fetchRequest = FlashCard.createFetchRequest()
        
        // Specify that we want to fetch distinct values for the provided properties
        fetchRequest.propertiesToFetch = ["category1", "category2", "category3"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .dictionaryResultType
        
        var results: [[String: Any]] = []
        
        do {
            let fetchedResults = try viewContext.fetch(fetchRequest)
            
            // Attempt to cast, but do not force unwrap
            if let castedResults = fetchedResults as? [[String: Any]] {
                results = castedResults
            } else {
                print("Failed to cast fetched results to [[String: Any]].")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results
    }

}

struct StacksGridView_Previews: PreviewProvider {
    static var previews: some View {
        MyStacks()
    }
}
