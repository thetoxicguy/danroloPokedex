//
//  Persistence.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 16/01/26.
//

//import CoreData
import SwiftData
import Foundation

@MainActor // The main thread to track for our view
struct PersistenceController {
//    The control for our database (static sets this variable only for the class, not the instances of it) (removed for SwiftData)
//    static let shared = PersistenceController()

//    ** This variable controls the sample preview database (See comment in PokemonDetail for the Preview)
    static var previewPokemon: Pokemon {
//        let context = PersistenceController.preview.container.viewContext
        
//        We know this exists because we set it in the "preview" variable which loads in the preview ***
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemonData = try! Data(contentsOf: Bundle.main.url(forResource: "samplepokemon", withExtension: "json")!)
        
        let pokemon = try! decoder.decode(Pokemon.self, from: pokemonData)
        
        return pokemon
    }
//    This is usually used in apps, but in this case we don't need MainActor (which gives an error two lines above
//    @MainActor
    static let preview: ModelContainer = {
//      this isStoredInMemoryOnly: true is to prevent the sample being feeded in our persistence data
        let container = try! ModelContainer(for: Pokemon.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(previewPokemon)
        
        return container
    }()

//    Remove the next for SwiftData refactor
//    The variable that contains all the persistent data (as a database)
//    let container: NSPersistentContainer
//
////    Just a regular init funcion
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "danroloPokedex")
//        if inMemory {
//            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//        }
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                print(error)
//            }
//        })
//        
////        Criteria for merging the data on error case. In this case: Keep the data that is already in the database
//        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
}
