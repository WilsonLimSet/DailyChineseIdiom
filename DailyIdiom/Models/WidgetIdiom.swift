struct WidgetIdiom: Codable {
    let characters: String
    let pinyin: String
    let meaning: String
    let example: String?
    let chineseExample: String?
    
    init(from idiom: Idiom) {
        self.characters = idiom.characters
        self.pinyin = idiom.pinyin
        self.meaning = idiom.meaning
        self.example = idiom.example
        self.chineseExample = idiom.chineseExample
    }
} 