//
//  ContentView.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 16/01/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all
    
    @FetchRequest<Pokemon>(
        // Core Data sorting
        //        NSSortDescriptor(keyPath: \Pokemon.id, ascending: true) is the legacy one, instead of:
        sortDescriptors: [SortDescriptor(\.id)], // ascending: true is the default behavior
        animation: .default) private var pokedex //: FetchedResults<Pokemon> The type is already stated in line 14 to be fed into pokedex
    
    @State private var searchText = ""
    @State var filterByFavorites = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
//        Search predicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", searchText))
        }
//        Filter by predicate
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d" , true))
        }
        
//        Combine predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    var body: some View {
        if all.isEmpty {
            ContentUnavailableView {
                Label("No Pokemons available", image: .nopokemon)
            } description: {
                Text("There aren't any pokemon yet.\nPlease, fetch some Pokemon to get started!")
            } actions: {
                Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            NavigationStack {
                List {
                    Section {
                        ForEach(pokedex) { pokemon in
                            //                    Usual code:
                            //                    NavigationLink {
                            //                        Text(pokemon.name ?? "No name")
                            //                    } label: {
                            //                        Text(pokemon.name ?? "No name")
                            //                    }
                            
                            //                    Alternate code
                            NavigationLink(value: pokemon) {
                                AsyncImage(url: pokemon.sprite) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                VStack(alignment: .leading) {
                                    HStack {
                                        // Exclamation is because we are sure this data exists (instead of using nullish coallescing)
                                        Text(pokemon.name!.capitalized)
                                            .fontWeight(.bold)
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    HStack {
                                        //                                Same here
                                        ForEach(pokemon.types!, id: \.self) { type in
                                            Text(type.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(Color(type.capitalized))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
//                            The default is .trailing
                            .swipeActions(edge: .leading) {
                                Button(
                                    pokemon.favorite ? "Remove from favorites" : "Add to favorites",
                                    systemImage: "star") {
                                        pokemon.favorite.toggle()
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if all.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokémon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\nFetch the rest of the Pokémon")
                            } actions: {
                                Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)}
                        }
                    }
                }
                .navigationTitle("Pokedex")
                .searchable(text: $searchText, prompt: "Find a Pokémon")
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .onChange(of: filterByFavorites) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .navigationDestination(for: Pokemon.self) { pokemon in
                    Text(pokemon.name ?? "No name")
                }
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterByFavorites.toggle()
                        } label: {
                            Label("Filter by Favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
//        These lines are for the usual behavior, we comment these to practice ContentUnavailableView
//        .task {
//            getPokemon()
//        }
    }
    private func getPokemon(from id: Int) {
        Task {
            for i in id..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
                    
//                    Set the fetchedPokemon in terms of the database storage
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
//                    Save the fetched
                    try viewContext.save()
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
