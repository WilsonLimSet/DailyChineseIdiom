struct Idiom: Codable, Equatable {
    let id: String
    let characters: String
    let pinyin: String
    let meaning: String
    let example: String?
    let chineseExample: String?
    let theme: String
    let description: String
    
    static func == (lhs: Idiom, rhs: Idiom) -> Bool {
        return lhs.id == rhs.id
    }
}

// Fallback sample idiom
let sampleIdiom = Idiom(
    id: "ID001",
    characters: "塞翁失马",
    pinyin: "sài wēng shī mǎ",
    meaning: "A blessing in disguise",
    example: "Losing his job led him to find his true calling",
    chineseExample: "失业反而让他找到了真正的使命",
    theme: "Life Philosophy",
    description: "This profound idiom originates from the story of a wise old man (塞翁) living near the northern border who lost his prized horse. When neighbors came to console him, he asked, 'How do you know this isn't good fortune?' Indeed, the horse later returned with a magnificent wild horse. When neighbors congratulated him, he remained cautious. Later, his son broke his leg while riding the wild horse, but this injury ultimately saved him from being conscripted into a war where many soldiers perished. The idiom teaches the Taoist principle that fortune and misfortune are interconnected and often transform into each other, encouraging us to maintain equilibrium in the face of life's ups and downs."
)