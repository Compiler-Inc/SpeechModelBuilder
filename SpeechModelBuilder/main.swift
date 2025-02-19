import Foundation
import Speech

// Configuration Protocol
@preconcurrency public protocol SpeechRecognitionConfiguration: Sendable {
    var locale: Locale { get }
    var silenceThreshold: Float { get }
    var silenceDuration: TimeInterval { get }
    var customModelURL: URL? { get }
    var appIdentifier: String { get }
    var modelVersion: String { get }
}

// Builder Struct
public struct SpeechTrainingBuilder {
    public struct PhraseDefinition {
        let phrase: String
        let count: Int
        let pronunciation: String?
    }
    
    public struct TemplateDefinition {
        let classes: [String: [String]]
        let template: String
        let count: Int
    }
    
    private var phrases: [PhraseDefinition] = []
    private var templates: [TemplateDefinition] = []
    
    public init() {}
    
    @discardableResult
    public mutating func addPhrase(_ phrase: String, count: Int = 10, pronunciation: String? = nil) -> Self {
        print("Adding phrase: \(phrase)")
        phrases.append(PhraseDefinition(phrase: phrase, count: count, pronunciation: pronunciation))
        return self
    }
    
    @discardableResult
    public mutating func addTemplate(classes: [String: [String]], template: String, count: Int = 100) -> Self {
        print("Adding template: \(template)")
        templates.append(TemplateDefinition(classes: classes, template: template, count: count))
        return self
    }
    
    public func build(config: SpeechRecognitionConfiguration) async throws -> URL {
        print("Building speech model...")
        print("Total phrases: \(phrases.count)")
        print("Total templates: \(templates.count)")
        
        let data = SFCustomLanguageModelData(
            locale: config.locale,
            identifier: config.appIdentifier,
            version: config.modelVersion
        ) {
            // Add phrases
            for phrase in phrases {
                if let pronunciation = phrase.pronunciation {
                    SFCustomLanguageModelData.CustomPronunciation(
                        grapheme: phrase.phrase,
                        phonemes: [pronunciation]
                    )
                }
                SFCustomLanguageModelData.PhraseCount(
                    phrase: phrase.phrase,
                    count: phrase.count
                )
            }
            
            // Add templates
            for template in templates {
                SFCustomLanguageModelData.PhraseCountsFromTemplates(
                    classes: template.classes
                ) {
                    SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template(
                        template.template,
                        count: template.count
                    )
                }
            }
        }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(config.appIdentifier)
            .appendingPathExtension("bin")
        
        try await data.export(to: outputURL)
        return outputURL
    }
}

// Example Configuration
struct ExampleConfig: SpeechRecognitionConfiguration {
    let locale = Locale(identifier: "en-US")
    let appIdentifier = "com.example.speechmodel" // Put your real bundle id here
    let modelVersion = "1.0"
    let silenceThreshold: Float = 0.1
    let silenceDuration: TimeInterval = 1.5
    let customModelURL: URL? = nil
}

print("Speech Model Builder Example")

let currentPath = FileManager.default.currentDirectoryPath
let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "\(currentPath)/speech_model.bin"

var builder = SpeechTrainingBuilder()

// Example 1: Custom vocabulary with X-SAMPA pronunciations
// These are words that speech recognition typically struggles with
// Use AI to help build your X-SAMPA Strings
builder.addPhrase("Winawer", count: 100, pronunciation: "wIn'aU@r")
builder.addPhrase("Tartakower", count: 100, pronunciation: "tArt@k'aU@r")

// Example 2: Context phrases using custom vocabulary
// Important: Add common phrases that use your custom words to help the model
// understand the context in which they appear
builder.addPhrase("Play the Winawer", count: 50)
builder.addPhrase("Play the Winawer variation", count: 50)
builder.addPhrase("The Tartakower defense", count: 50)
builder.addPhrase("Play the Tartakower", count: 50)

// Example 3: Template for chess moves
// This shows how to combine standard vocabulary with custom words
// The template system will generate all possible combinations
builder.addTemplate(
    classes: [
        "piece": [
            "pawn",
            "rook",
            "knight",
            "bishop",
            "queen",
            "king"
        ],
        "royal": [
            "queen",
            "king"
        ],
        "rank": ["1", "2", "3", "4", "5", "6", "7", "8"],
        "opening": [
            "Winawer",
            "Tartakower"
        ]
    ],
    template: "<piece> to <royal> <rank>",
    count: 1000
)

// Example 4: Template for chess commentary
// This demonstrates how to create natural language patterns
// that mix custom vocabulary with common phrases
builder.addTemplate(
    classes: [
        "prefix": [
            "Let's play",
            "I suggest",
            "We should try",
            "Consider"
        ],
        "opening": [
            "the Winawer",
            "the Tartakower"
        ],
        "suffix": [
            "variation",
            "defense",
            "line",
        ]
    ],
    template: "<prefix> <opening> <suffix>",
    count: 500
)

// Note: When building a speech model:
// 1. Start with custom vocabulary and their pronunciations
// 2. Add common phrases that use these words
// 3. Create templates that combine custom and standard vocabulary
// 4. Include variations of how people naturally speak these phrases
// This helps the model understand both the pronunciation and context

Task {
    do {
        let modelURL = try await builder.build(config: ExampleConfig())
        let outputURL = URL(fileURLWithPath: outputPath)
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        try FileManager.default.copyItem(at: modelURL, to: outputURL)
        
        print("✅ Model exported successfully to: \(outputURL.path)")
        exit(0)
    } catch {
        print("❌ Error building model: \(error)")
        exit(1)
    }
}

RunLoop.main.run()
