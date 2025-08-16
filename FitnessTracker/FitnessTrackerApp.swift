import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

@main
struct FitnessTrackerApp: App {
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
    
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch {
            print("Could not initialize Amplify", error)
        }
    }
}
