//
//  PokemonDetail.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 21/01/26.
//

import SwiftUI

struct PokemonDetail: View {
//    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.managedObjectContext) private var modelContext
    var pokemon: Pokemon
    
    @State private var showShiny = false
    var body: some View {
//        GeometryReader { geo in
            ScrollView {
                ZStack {
                    Image(pokemon.background)
                        .resizable()
                        .scaledToFit()
//                        .frame(width: geo.size.width, height: geo.size.height)
                        .shadow(radius: 6)
                    //                if showShiny {
                    //                    Image("\(pokemon.id!)-shiny")
                    //                        .
                   
                    if pokemon.sprite == nil || pokemon.shiny == nil {
                        AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL ) { image in
                            image
                            //                        Interpolation fixes the image aspect ratio
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .padding(.top, 50)
                                .shadow(color: .black, radius: 6)
                        } placeholder: {
                            ProgressView()
                        }
                        //                }
                    } else {
                        (showShiny ? pokemon.shinyimage : pokemon.spriteImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 50)
                            .shadow(color: .black, radius: 6)
                    }
                }
                HStack {
                    ForEach(pokemon.types, id: \.self) { type in
                        Text(type.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .shadow(color: .white, radius: 1)
                            .padding(.horizontal)
                            .padding(.vertical, 7)
                            .background(Color(type.capitalized))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Button {
                        pokemon.favorite.toggle()
                        
                        do {
                            try modelContext.save()
                        } catch {
                            print(error)
                        }
                    } label: {
                        Image(systemName: pokemon.favorite ? "star.fill" : "star")
                            .font(.largeTitle)
                            .tint(.yellow)
                    }
                }
                .padding()
                Text("Stats:")
                    .font(.title)
                    .padding(.bottom, -7)
                Stats(pokemon: pokemon)
                    
            }
//        }
        .navigationTitle(pokemon.name.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                        .tint(showShiny ? .yellow : .primary)
                }
            }
        }
//        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        PokemonDetail(pokemon: PersistenceController.previewPokemon)
    }
}
