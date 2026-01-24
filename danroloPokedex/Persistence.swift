//
//  Persistence.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 16/01/26.
//

import CoreData

struct PersistenceController {
//    The control for our database (static sets this variable only for the class, not the instances of it)
    static let shared = PersistenceController()

//    ** This variable controls the sample preview database (See comment in PokemonDetail for the Preview)
    static var previewPokemon: Pokemon {
        let context = PersistenceController.preview.container.viewContext
        
//        We know this exists because we set it in the "preview" variable which loads in the preview ***
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try! context.fetch(fetchRequest)
        
//        Same as *** above
        return results.first!
    }
//    This is usually used in apps, but in this case we don't need MainActor (which gives an error two lines above
//    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newPokemon = Pokemon(context: viewContext)
        newPokemon.id = 1
        newPokemon.name = "bulbasaur"
        newPokemon.types = ["grass", "poison"]
        newPokemon.hp = 45
        newPokemon.attack = 49
        newPokemon.defense = 49
        newPokemon.specialAttack = 65
        newPokemon.specialDefense = 65
        newPokemon.speed = 45
        newPokemon.spriteURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        newPokemon.shinyURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        return result
    }()

//    The variable that contains all the persistent data (as a database)
    let container: NSPersistentContainer

//    Just a regular init funcion
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "danroloPokedex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
            }
        })
        
//        Criteria for merging the data on error case. In this case: Keep the data that is already in the database
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
