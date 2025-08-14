//
//  ToDoApp.swift
//  ToDo
//
//  Created by Marcelina Ziółkiewicz on 14/08/2025.
//

import SwiftUI
import FirebaseCore

@main
struct ToDoApp: App {
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
