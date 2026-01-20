//
//  Untitled.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 20/01/26.
//

import Foundation

struct FetchedPokemon: Decodable {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialdefense: Int16
    let speed: Int16
    let sprite: URL
    let shiny: URL
    
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
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.types = try container.decode([String].self, forKey: .types)
        self.hp = try container.decode(Int16.self, forKey: .hp)
        self.attack = try container.decode(Int16.self, forKey: .attack)
        self.defense = try container.decode(Int16.self, forKey: .defense)
        self.specialAttack = try container.decode(Int16.self, forKey: .specialAttack)
        self.specialdefense = try container.decode(Int16.self, forKey: .specialdefense)
        self.speed = try container.decode(Int16.self, forKey: .speed)
        self.sprite = try container.decode(URL.self, forKey: .sprite)
        self.shiny = try container.decode(URL.self, forKey: .shiny)
    }
}
