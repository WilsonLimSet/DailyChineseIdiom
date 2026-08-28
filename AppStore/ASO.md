# App Store metadata — ready to paste

App: ChengYu / Daily Chinese Idioms — App Store ID `6740611324`

Everything below is written to Apple's field limits and checked against them. Paste each
block into App Store Connect → **App Store** tab → the matching field, per language.

Screenshots are deliberately untouched — the current set stays as is.

---

## 1. English (U.S.) — primary locale

### App Name — leave it alone

Your live name is already `ChengYu - Daily Chinese Idioms` — exactly 30/30 characters, and it
already carries the three highest-value search terms (*chengyu*, *Chinese*, *idioms*) plus the
brand. There is nothing to gain here; changing it would only risk brand recognition. Verified
in App Store Connect, so ignore any advice to rename it.

The real opportunities are the subtitle, keywords, and promotional text below.

### Subtitle (30 max) — 29 chars

```
Learn Mandarin proverbs daily
```

Why: adds *Mandarin*, *proverb*, *learn*, *daily* without repeating a single word from the
name. Apple indexes name + subtitle + keywords as one bag of words, so repeats are wasted
characters.

### Keywords (100 max) — 98 chars

```
hanzi,pinyin,hsk,vocabulary,flashcard,widget,saying,phrase,zhongwen,traditional,simplified,culture
```

Rules applied: no spaces after commas (each space costs a character), no word repeated from
the name or subtitle, no plurals where the singular already covers it, and no competitor
brand names (Apple rejects those).

### Promotional Text (170 max) — can be updated any time without a new build

```
New: show the literal meaning, the deeper meaning, or both — in the app and on every widget. Settings now sync to widgets instantly, and audio plays even on silent.
```

### Description

```
One Chinese idiom a day, right on your home screen.

Chengyu (成语) are four-character idioms that carry centuries of Chinese history in a single phrase. ChengYu gives you one a day — with pinyin, meaning, a real example, and the story behind it.

WIDGETS THAT ACTUALLY TEACH YOU
Put a chengyu on your home screen in three sizes. Small shows the characters and pinyin, medium and large add the meaning and an example sentence. It changes at midnight, so you learn one without opening an app.

BOTH MEANINGS, YOUR CHOICE
Every idiom has a literal translation and a deeper meaning. 塞翁失马 literally means "the old man loses his horse" — but it really means misfortune may be a blessing in disguise. Show either, or show both, in the app and on your widgets.

SIMPLIFIED OR TRADITIONAL
Switch between 简体 and 繁體 characters at any time. Examples and descriptions switch with them.

HEAR IT SPOKEN
Tap to hear native Mandarin pronunciation of any idiom, with support for enhanced iOS voices.

BUILT FOR DAILY LEARNING
• A new idiom every day, plus the full history of past ones
• Save your favorites for review
• Real example sentences in Chinese and English
• The cultural story behind each idiom
• Share any idiom as an image

FREE, WITH NO ADS AND NO TRACKING
ChengYu is completely free. There are no ads, no accounts, no analytics, and nothing is collected about you. If you'd like to support development, there's an optional tip jar in Settings — it unlocks nothing, because everything is already unlocked.

Perfect for HSK students, heritage speakers, teachers, and anyone who wants a little more Chinese in their day.
```

### What's New (this release)

```
• Fixed: character and meaning settings now apply to widgets. Changing simplified/traditional or literal/deeper in the app updates every widget right away.
• Fixed: pronunciation audio now plays even when your phone is on silent.
• New: show the literal meaning, the deeper meaning, or both at once — in the app and on widgets.
• New: an optional tip jar in Settings, for anyone who wants to support a free, ad-free app.
```

---

## 4. Order of operations in App Store Connect

1. Create the new iOS version (1.93).
2. Paste the English fields. The app name stays as it is.
3. Promotional Text can be changed any time without review — use it to announce things.
4. Attach the two tip-jar IAPs to the version, then submit with the new build.

## 5. Things worth doing after this, in order of payoff

- **Ship the widget-settings fix.** Two of your recent reviews are about it. Rating is the
  biggest single multiplier on conversion, and you already prompt for reviews in-app.
- **Localize to Japanese and Korean later.** Four-character idioms (四字熟語 / 사자성어)
  are a familiar concept in both markets, and the competition there is thin. Ask when you
  want the copy.
- **Custom Product Pages** (free, unlimited): make one that leads with the widget for
  linking from Reddit/social, so the traffic lands on a page written for that audience.
- Post the widget on r/ChineseLanguage and r/Mandarin. That subreddit converts well for
  study tools, and a widget screenshot is the kind of thing people upvote.

## 6. Parked: Chinese localizations — decided against

Decision (2026-08-18): not shipping zh-Hans/zh-Hant. ~99% of users are English speakers
learning Chinese, so Chinese-language listings would serve heritage speakers and parents,
not the core audience. The drafted copy is kept below in case that ever changes.

### A cheaper alternative aimed at the SAME audience

Apple indexes each localization's keyword field separately, including other *English*
locales. Adding English (U.K.), English (Australia), and English (Canada) gives you up to
three more 100-char keyword fields targeting English-speaking learners, with the same
screenshots and near-identical copy. That is the version of "more localizations" worth
doing for this app. Ask and I'll draft the keyword variants.

---

## Appendix: parked Chinese copy

## 2. 简体中文 (zh-Hans)

### App Name (30 max)

```
成语每日学：中文成语小组件
```

### Subtitle (30 max)

```
每天一个成语，拼音释义例句与典故
```

### Keywords (100 max)

```
成语,汉语,词汇,拼音,繁体,简体,俗语,谚语,典故,国学,词典,语文,小学,识字,四字,中文,学习,卡片,发音,普通话,文化,故事,hsk,widget
```

### Description

```
每天一个成语，就在你的主屏幕上。

成语是四个字里装下的千年故事。本应用每天为你推送一个成语，包含拼音、释义、例句，以及它背后的典故。

主屏幕小组件
支持小、中、大三种尺寸。小尺寸显示成语与拼音，中大尺寸还会显示释义和例句。每天午夜自动更新。

字面义与引申义
每个成语都有字面意思和深层含义。「塞翁失马」字面是老翁丢了马，真正的意思却是祸福相依。你可以选择显示其中之一，或者两者同时显示。

简体与繁体
随时切换简体字与繁体字，例句和说明会一起切换。

普通话发音
点击即可听标准普通话发音，支持 iOS 增强语音。

完全免费
没有广告，没有账号，不收集任何数据。设置中有一个可选的打赏入口——它不解锁任何功能，因为所有功能本来就是免费的。
```

---

## 3. 繁體中文 (zh-Hant)

### App Name (30 max)

```
成語每日學：中文成語小工具
```

### Subtitle (30 max)

```
每天一個成語，拼音釋義例句與典故
```

### Keywords (100 max)

```
成語,漢語,詞彙,拼音,繁體,簡體,俗語,諺語,典故,國學,辭典,國文,小學,識字,四字,中文,學習,卡片,發音,國語,文化,故事,hsk,widget
```

### Description

```
每天一個成語，就在你的主畫面上。

成語是四個字裡裝下的千年故事。本應用每天為你推送一個成語，包含拼音、釋義、例句，以及它背後的典故。

主畫面小工具
支援小、中、大三種尺寸。小尺寸顯示成語與拼音，中大尺寸還會顯示釋義和例句。每天午夜自動更新。

字面義與引申義
每個成語都有字面意思和深層含義。「塞翁失馬」字面是老翁丟了馬，真正的意思卻是禍福相依。你可以選擇顯示其中之一，或者兩者同時顯示。

繁體與簡體
隨時切換繁體字與簡體字，例句和說明會一起切換。

國語發音
點擊即可聽標準國語發音，支援 iOS 增強語音。

完全免費
沒有廣告，沒有帳號，不蒐集任何資料。設定中有一個可選的贊助入口——它不解鎖任何功能，因為所有功能本來就是免費的。
```

---


---

## 7. What is actually LIVE vs. drafted — check this first (2026-08-27)

The subtitle drafted in section 1 was **never applied**. It sat empty from v1.07 through
v1.93 — roughly a year of launches with 30 indexed characters unused. The keywords *did*
ship. Nothing above is live until you verify it against the API:

```
python3 scripts/asc.py show                     # editable version only
python3 scripts/asc_sales.py 60                 # downloads + IAP, ChengYu-filtered
python3 scripts/asc_analytics.py reports engagement
```

**Staged on version 1.94 (`PREPARE_FOR_SUBMISSION`, not submitted):**

| Field | Value |
|---|---|
| Subtitle (all 4 locales) | `Learn Mandarin proverbs` (23/30) |
| en-US keywords | unchanged, 98/100 |
| en-GB keywords | `study,character,language,quote,wisdom,expression,dictionary,translate,putonghua,exam,speak` (90) |
| en-AU keywords | `beginner,practice,review,story,history,calligraphy,tone,lockscreen,homescreen,word,day` (86) |
| en-CA keywords | `cantonese,teacher,kids,school,reading,writing,listening,memorize,quiz,fluent,course,yct` (87) |

Indexed keyword characters went from 98 to **361**. Apple indexes each locale's keyword
field separately, so en-GB/AU/CA are three more bites at the same English-speaking learner
— no term repeats the app name, the subtitle, or another locale's list.

The drafted subtitle `Learn Mandarin proverbs daily` was cut to drop *daily*, which already
appears in the app name; Apple treats name + subtitle + keywords as one bag of words, so the
repeat was ~6 wasted characters of 30.

**1.94 still needs a build.** Subtitle, keywords and locales are version-scoped, and Apple
will not accept a version without a build attached — there is no metadata-only submission
path. Promotional Text is the only field that changes without review. See `RELEASE.md`.

**Expect a modest result.** As of 2026-08-27 the app takes ~20 new downloads/week, flat for
two months, against an active base of ~840. Better search coverage plausibly moves that
20-50%. It does not move it 35x, which is what tip revenue of $10/week would require — see
[[chengyu-tip-revenue-goal]]. Distribution outside App Store search is the only lever at
that scale.
