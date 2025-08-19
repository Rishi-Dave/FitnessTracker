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
            ContentView()
        }
    }
    
    func configureAmplify() {
        do {
            // Add plugins
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            // Configure Amplify
            try Amplify.configure()
            
            print("✅ Amplify configured successfully")
            
            // Log configuration details (DEBUG only)
            #if DEBUG
            logAmplifyConfiguration()
            #endif
            
        } catch {
            print("❌ Could not initialize Amplify: \(error)")
            
            // In production, you might want to show an error to the user
            // or fall back to offline mode
        }
    }
    
    #if DEBUG
    private func logAmplifyConfiguration() {
        print("🔧 AMPLIFY CONFIGURATION DEBUG")
        print("════════════════════════════════")
        
        // Check if configuration file exists
        if let configPath = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json") {
            print("✅ Configuration file found at: \(configPath)")
            
            // Try to read and validate configuration
            do {
                let configData = try Data(contentsOf: URL(fileURLWithPath: configPath))
                let configJSON = try JSONSerialization.jsonObject(with: configData) as? [String: Any]
                
                // Check API configuration
                if let api = configJSON?["api"] as? [String: Any],
                   let plugins = api["plugins"] as? [String: Any],
                   let awsAPI = plugins["awsAPIPlugin"] as? [String: Any] {
                    
                    for (key, value) in awsAPI {
                        if let config = value as? [String: Any] {
                            print("📡 API Endpoint '\(key)':")
                            print("   - Endpoint: \(config["endpoint"] as? String ?? "Not found")")
                            print("   - Region: \(config["region"] as? String ?? "Not found")")
                            print("   - Auth Type: \(config["authorizationType"] as? String ?? "Not found")")
                        }
                    }
                }
                
                // Check Auth configuration
                if let auth = configJSON?["auth"] as? [String: Any],
                   let plugins = auth["plugins"] as? [String: Any],
                   let cognitoAuth = plugins["awsCognitoAuthPlugin"] as? [String: Any],
                   let userPool = cognitoAuth["CognitoUserPool"] as? [String: Any],
                   let defaultPool = userPool["Default"] as? [String: Any] {
                    
                    print("🔐 Auth Configuration:")
                    print("   - Pool ID: \(defaultPool["PoolId"] as? String ?? "Not found")")
                    print("   - Client ID: \(defaultPool["AppClientId"] as? String ?? "Not found")")
                    print("   - Region: \(defaultPool["Region"] as? String ?? "Not found")")
                }
                
            } catch {
                print("❌ Error reading configuration: \(error)")
            }
        } else {
            print("❌ Configuration file not found!")
            print("📝 Make sure 'amplifyconfiguration.json' is in your bundle")
        }
        
        print("════════════════════════════════")
    }
    #endif
}
