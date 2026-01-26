//
//  ContentView.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 16/01/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.modelContext) private var modelContext
    
//    @FetchRequest<Pokemon>(sortDescriptors: []) private var all
    
//    @FetchRequest<Pokemon>(
//        // Core Data sorting
//        //        NSSortDescriptor(keyPath: \Pokemon.id, ascending: true) is the legacy one, instead of:
//        sortDescriptors: [SortDescriptor(\.id)], // ascending: true is the default behavior
//        animation: .default) private var pokedex //: FetchedResults<Pokemon> The type is already stated in line 14 to be fed into pokedex

    @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
    
    @State private var searchText = ""
    @State var filterByFavorites = false
    
    let fetcher = FetchService()

//    SwiftData predicates
    private var dynamicPredicate: Predicate<Pokemon> {
        #Predicate<Pokemon> { pokemon in
            if filterByFavorites && !searchText.isEmpty {
                pokemon.favorite && pokemon.name.localizedStandardContains(searchText)
            } else if !searchText.isEmpty {
                pokemon.name.localizedStandardContains(searchText)
            } else if filterByFavorites {
                pokemon.favorite
            } else {
                true
            }
        }
    }
    
    var body: some View {
        if pokedex.isEmpty {
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
                        ForEach((try? pokedex.filter(dynamicPredicate)) ?? pokedex) { pokemon in
                            //                    Usual code:
                            //                    NavigationLink {
                            //                        Text(pokemon.name ?? "No name")
                            //                    } label: {
                            //                        Text(pokemon.name ?? "No name")
                            //                    }
                            
                            //                    Alternate code
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        // Exclamation is because we are sure this data exists (instead of using nullish coallescing)
                                        Text(pokemon.name.capitalized)
                                            .fontWeight(.bold)
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    HStack {
                                        //                                Same here
                                        ForEach(pokemon.types, id: \.self) { type in
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
                                            try modelContext.save()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if pokedex.count < 151 {
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
                .animation(.default, value: searchText)
//                These onChange modifiers are removed because the predicates will change for SwiftData
//                .onChange(of: searchText) {
//                    pokedex.nsPredicate = dynamicPredicate
//                }
//                .onChange(of: filterByFavorites) {
//                    pokedex.nsPredicate = dynamicPredicate
//                }
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail(pokemon: pokemon)
//                        .environmentObject(pokemon) // This intriduces problems with SwiftData
                }
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                filterByFavorites.toggle()
                            }
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

                    modelContext.insert(fetchedPokemon)
                } catch {
                    print(error)
                }
            }
            await storeSprites()
        }
    }
    
    private func storeSprites() async {
        do {
            for pokemon in pokedex {
//                We get the content of the tuple at the slot 0
                pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
                pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
//                    Save the fetched Pokémon images
                try modelContext.save()
                print("Sprite stored: \(pokemon.id): \(pokemon.name.capitalized)")
            }
         } catch {
             print(error)
        }
    }
}

#Preview {
    ContentView().modelContainer(PersistenceController.preview)
}
