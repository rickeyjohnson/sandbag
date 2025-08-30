//
//  SandbagApp.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/23/25.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

@main
struct SandbagApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
