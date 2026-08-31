import Foundation

/// One-time repair of stored favorites after the idiom library was rebuilt for 1.95.
///
/// Favorites are stored as bare idiom IDs, and `FavoritesManager.favoriteIdioms` resolves them
/// with `compactMap`, so an ID that no longer exists disappears from the user's list without a
/// word. Two things happened to IDs between 1.94 and 1.95 that would trigger exactly that:
///
/// 1. Duplicate entries were merged, so 28 IDs stopped existing while the idiom they named
///    survived under a different ID.
/// 2. `ID681` was reused: it named 巧夺天工 in every shipped build and now names 卧虎藏龙.
///    Anyone who favorited the former would silently find the latter in its place.
///
/// Both are fixed by rewriting the stored list once. This is safe to run exactly once and no
/// more — after the migration a user can legitimately favorite 卧虎藏龙 *as* `ID681`, and
/// re-running the map would then corrupt a correct entry. `migrationVersion` enforces that.
///
/// These IDs were corrected in place and deliberately have no alias entry, because the favorite
/// should stay put and now resolves to the corrected idiom:
/// - `ID050` 金石良言 -> 金玉良言
/// - `ID558` 固步自封 -> 故步自封
///
/// These were removed as not genuine chengyu, so favorites pointing at them resolve to nothing
/// and are left alone rather than deleted:
/// - 以心换心 (ID008)
/// - 守时如金 (ID020)
/// - 拔苗助长 (ID190)
/// - 走马观花 (ID202)
/// - 纸上富贵 (ID257)
/// - 心地善良 (ID313)
/// - 待人热情 (ID314)
/// - 乐于助人 (ID315)
/// - 毫无疑问 (ID326)
/// - 长话短说 (ID338)
/// - 唱空城计 (ID339)
/// - 争论不休 (ID471)
/// - 破天荒 (ID485)
/// - 春风满面 (ID586)
/// - 成竹在胸 (ID666)
enum FavoritesMigration {

    static let migrationVersionKey = "favoritesMigrationVersion"
    static let currentVersion = 1

    /// Left: an ID that shipped in 1.94 or earlier. Right: where that same idiom lives now.
    /// Several old IDs collapse onto one new ID, so the result must be de-duplicated.
    static let renamedIDs: [String: String] = [
        "ID427": "ID222",   // 鹤发童颜
        "ID432": "ID332",   // 不言而喻
        "ID481": "ID053",   // 胸有成竹
        "ID562": "ID540",   // 妄自菲薄
        "ID564": "ID423",   // 患得患失
        "ID568": "ID415",   // 喜出望外
        "ID575": "ID434",   // 垂头丧气
        "ID588": "ID412",   // 光明磊落
        "ID591": "ID539",   // 言行一致
        "ID604": "ID531",   // 心心相印
        "ID607": "ID385",   // 天长地久
        "ID609": "ID494",   // 依依不舍
        "ID622": "ID484",   // 鞠躬尽瘁
        "ID632": "ID390",   // 循序渐进
        "ID633": "ID528",   // 按部就班
        "ID634": "ID397",   // 脚踏实地
        "ID639": "ID440",   // 势如破竹
        "ID645": "ID386",   // 马到成功
        "ID646": "ID436",   // 一帆风顺
        "ID658": "ID464",   // 恰到好处
        "ID659": "ID411",   // 恰如其分
        "ID660": "ID500",   // 无懈可击
        "ID661": "ID172",   // 滴水不漏
        "ID665": "ID053",   // 胸有成竹
        "ID671": "ID460",   // 炉火纯青
        "ID673": "ID071",   // 登堂入室
        "ID674": "ID021",   // 青出于蓝
        "ID675": "ID391",   // 后来居上
        "ID681": "ID175",   // 巧夺天工
    ]

    /// Rewrites a stored favorites list, preserving order and dropping duplicates created by
    /// the merge (a user who favorited both copies of an idiom should end up with one).
    static func migrate(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        return ids
            .map { renamedIDs[$0] ?? $0 }
            .filter { seen.insert($0).inserted }
    }
}
