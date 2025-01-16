struct Idiom: Codable {
    let id: String
    let characters: String
    let pinyin: String
    let meaning: String
    let example: String?
    let chineseExample: String?
    let theme: String
    let description: String
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
    description: "This story comes from a famous Chinese parable about an old man whose lost horse returned with more horses."
)