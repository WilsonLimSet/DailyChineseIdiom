struct Idiom: Codable {
    let characters: String      // Chinese characters
    let pinyin: String         // Pinyin pronunciation
    let meaning: String        // English meaning
    let example: String?       // Example sentence
    let chineseExample: String?
    let theme: String
    let description: String
} 