//
//  MovementStore.swift
//  FinanzasApp
//
//  Persistencia local ligera (UserDefaults + JSON).
//  Diseñado para poder migrar a CoreData/SwiftData más adelante sin romper MVVM.
//

import Foundation

protocol MovementStoreProtocol {
    func load() throws -> [Movement]
    func save(_ movements: [Movement]) throws
}

enum MovementStoreError: Error {
    case encodingFailed
    case decodingFailed
}

final class MovementStore: MovementStoreProtocol {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "finanzasapp.movements.v1") {
        self.defaults = defaults
        self.key = key
    }

    func load() throws -> [Movement] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([Movement].self, from: data)
        } catch {
            throw MovementStoreError.decodingFailed
        }
    }

    func save(_ movements: [Movement]) throws {
        do {
            let data = try JSONEncoder().encode(movements)
            defaults.set(data, forKey: key)
        } catch {
            throw MovementStoreError.encodingFailed
        }
    }
}


