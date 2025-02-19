# Speech Model Builder

A Swift CLI tool to help you build custom speech recognition models for iOS 17+ using `SFCustomLanguageModelData`.

## Overview

Sometimes `SFSpeechRecognizer` can get confused on specific technical terms or proper nouns. Starting in iOS 17, you can build a speech model using `SFCustomLanguageModelData` that includes specific vocabulary and phrases that use that vocabulary. This CLI tool helps you build phrases and templates easily.

## Features

- Easy to use builder pattern for adding phrases and templates
- Support for X-SAMPA pronunciation strings
- Template system for generating common phrase patterns
- Built-in examples for custom vocabulary handling
- Generates `.bin` files ready to use in your iOS projects

## Quick Start

1. Clone this repo
2. Start adding your phrases and templates in `main.swift`. To build the pronunciation, `SFCustomLanguageModelData` uses X-SAMPA strings ([X-SAMPA Reference](https://en.wikipedia.org/wiki/X-SAMPA)). AI is really good at generating these, so highly recommend you use an AI tool (Cursor or other AI-enabled IDEs are really good for this).
3. Run the tool:
   ```bash
   swift main.swift [optional_output_path]
   ```
   Or open and run in Xcode
4. It will generate a `.bin` file that you can drag into your iOS project

## Example Usage

```swift
var builder = SpeechTrainingBuilder()

// 1. Add custom vocabulary with pronunciations
builder.addPhrase("Winawer", count: 100, pronunciation: "wIn'aU@r")

// 2. Add context phrases
builder.addPhrase("Play the Winawer variation", count: 50)

// 3. Create templates for common patterns
builder.addTemplate(
    classes: [
        "prefix": ["Let's play", "Consider"],
        "opening": ["the Winawer"],
        "suffix": ["variation", "defense"]
    ],
    template: "<prefix> <opening> <suffix>",
    count: 500
)
```

## Best Practices

When building a speech model:
1. Start with custom vocabulary and their pronunciations
2. Add common phrases that use these words
3. Create templates that combine custom and standard vocabulary
4. Include variations of how people naturally speak these phrases

This helps the model understand both the pronunciation and context of your custom vocabulary.

## Integration

[Coming Soon: Link to SpeechRecognizerService repo for easy integration]

## Requirements

- iOS 17.0+
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Documentation

For more information about speech recognition in iOS, see Apple's documentation:
- [Recognizing Speech in Live Audio](https://developer.apple.com/documentation/Speech/recognizing-speech-in-live-audio)

## Tips for X-SAMPA

The X-SAMPA pronunciation strings can be tricky to get right. Here are some tips:
- Use AI tools to help generate the strings
- Common patterns:
  - Stress mark: `'` before stressed syllable
  - Syllable boundary: `.`
  - Schwa sound: `@`
  - Long vowels: Add `:`
  - Example: `'tEm.poU` for "tempo"

## License

MIT License