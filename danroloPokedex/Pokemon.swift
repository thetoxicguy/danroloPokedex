//
//  Pokemon.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 26/01/26.
//
//

import Foundation
import SwiftData
import SwiftUI


@Model // This line turns the class into a SwiftData model for storage
class Pokemon: Decodable { // Given that now this is decodable, we don't need our FetchedPokemon
//    #Unique<Pokemon>([\.id]) // We substitute this line by addin @Attribute(.unique) next
    @Attribute(.unique) var id: Int
    var name: String
    var types: [String]
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int
    var spriteURL: URL
    var shinyURL: URL
    var shiny: Data?
    var sprite: Data?
    var favorite: Bool = false
    
//    Instead of FetchedPokemon, we  substitute this enum and the following init (remove FetchedPokemon)
//    public init(name: String, shinyURL: URL, spriteURL: URL, types: [String]) {
//        self.name = name
//        self.shinyURL = shinyURL
//        self.spriteURL = spriteURL
//        self.types = types
//
//    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: CodingKey {
            case type
            
            enum TypeKeys: CodingKey {
                case name
            }
        }
        
        enum StatsDictionaryKeys: CodingKey {
            case baseStat
        }
        
        enum SpriteKeys: String, CodingKey {
            case spriteURL = "frontDefault"
            case shinyURL = "frontShiny"
        }
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        var decodedTypes: [String] = []
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        while !typesContainer.isAtEnd {
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            let typeContainer = try typesDictionaryContainer.nestedContainer(
                keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self,
                forKey: .type
            )
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        
        if decodedTypes.count > 1 && decodedTypes[0] == "normal" {
            decodedTypes.swapAt(0, 1)
        }
        types = decodedTypes
        
        var decodedStats: [Int] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatsDictionaryKeys.self)
            let stat = try statsDictionaryContainer.decode(Int.self, forKey: .baseStat)
            decodedStats.append(stat)
        }
        
        hp = decodedStats[0]
        attack = decodedStats[1]
        defense = decodedStats[2]
        specialAttack = decodedStats[3]
        specialDefense = decodedStats[4]
        speed = decodedStats[5]
        
        let spriteContainer =  try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
        shinyURL = try spriteContainer.decode(URL.self, forKey: .shinyURL)
    }
    
// We add the extension setup (PokemonExt) that was needed for our Core Data configuration
    var spriteImage:  Image {
        if let data = sprite, let image =  UIImage(data: data) {
            Image (uiImage: image)
        } else {
            Image(.bulbasaur)
        }
    }
    
    var shinyimage:  Image {
        if let data = shiny, let image =  UIImage(data: data) {
            Image (uiImage: image)
        } else {
            Image(.shinybulbasaur)
        }
    }
    
    var background: ImageResource {
        switch types[0] {
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case "ice":
                .ice
        case "water":
                .water
        default:
                .normalgrasselectricpoisonfairy
        }
    }
    var typeColor: Color {
        Color(types[0].capitalized)
    }
    //    With this variable, we are indexing the stats in the right way
    var stats: [Stat] {
        [
            Stat(id: 1, name: "HP", value: hp),
            Stat(id: 2, name: "Attack", value: attack),
            Stat(id: 3, name: "Defense", value: defense),
            Stat(id: 4, name: "Special Attack", value: specialAttack),
            Stat(id: 5, name: "Special Defense", value: specialDefense),
            Stat(id: 6, name: "Speed", value: speed)
        ]
    }
    var highestStat: Stat {
        //        This is the short version of the next comment
        stats.max { $0.value < $1.value}!
        //        stats.max { stat1, stat2 in
        //            stat1.value < stat2.value
        //        }!
    }

    struct Stat: Identifiable {
        let id: Int // Identifier for the stat
        var name: String // The stat name
        var value: Int // The integer value of the stat
        
    }
}
