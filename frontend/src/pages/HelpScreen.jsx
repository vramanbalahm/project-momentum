import { useState } from "react";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0",
  text: "#2C2C2A", muted: "#888780",
};

const SECTIONS = [
  {
    id: "recipe_review",
    title: "Recipe Review",
    title_ta: "சமையல் குறிப்பு மதிப்பாய்வு",
    icon: "📋",
    fields: [
      {
        label: "Diet Type",
        label_ta: "உணவு வகை",
        en: "Describes what kind of ingredients the recipe uses:\n• Veg — vegetarian, may include dairy (ghee, milk, curd)\n• Vegan — no dairy or eggs, only plant-based ingredients\n• Eggitarian — includes eggs but no meat or seafood\n• Non-Veg — includes meat or seafood\n\nExample: Idli is Veg. Appam with coconut milk is Vegan. Egg curry is Eggitarian. Chicken kuzhambu is Non-Veg.",
        ta: "சமையல் குறிப்பில் என்ன வகையான பொருட்கள் பயன்படுத்தப்படுகின்றன என்பதை விவரிக்கிறது:\n• Veg — சைவம், பால் பொருட்கள் சேர்க்கலாம் (நெய், பால், தயிர்)\n• Vegan — பால் பொருட்கள் அல்லது முட்டை இல்லை\n• Eggitarian — முட்டை சேர்க்கலாம், இறைச்சி வேண்டாம்\n• Non-Veg — இறைச்சி அல்லது கடல் உணவு சேர்க்கலாம்\n\nஎடுத்துக்காட்டு: இட்லி = Veg. தேங்காய் பால் ஆப்பம் = Vegan. முட்டை குழம்பு = Eggitarian. கோழி குழம்பு = Non-Veg.",
      },
      {
        label: "Meal Slots",
        label_ta: "உணவு நேரம்",
        en: "When is this dish typically served?\n• Breakfast — morning meal (idli, dosa, pongal)\n• Lunch — midday meal (rice, kuzhambu, sambar)\n• Dinner — evening meal (chapati, parotta, light rice)\n• Side Dish — served alongside a main dish (chutney, poriyal, rasam)\n\nA dish can belong to multiple slots. Example: Idli can be Breakfast or Dinner. Sambar is a Side Dish.",
        ta: "இந்த உணவு வழக்கமாக எப்போது பரிமாறப்படுகிறது?\n• Breakfast — காலை உணவு (இட்லி, தோசை, பொங்கல்)\n• Lunch — மதிய உணவு (சோறு, குழம்பு, சாம்பார்)\n• Dinner — இரவு உணவு (சப்பாத்தி, பரோட்டா)\n• Side Dish — முக்கிய உணவுடன் பரிமாறப்படும் (சட்னி, பொரியல், ரசம்)\n\nஒரு உணவு பல நேரங்களில் சேர்க்கலாம். எடுத்துக்காட்டு: இட்லி காலை மற்றும் இரவு இரண்டிலும் சேர்க்கலாம்.",
      },
      {
        label: "Satvik",
        label_ta: "சாத்விக்",
        en: "Satvik food follows traditional Hindu dietary principles:\n• No onion\n• No garlic\n• No meat or eggs\n• Suitable for fasting days and religious occasions\n\nExample: Plain dal, vegetable kootu without onion/garlic, fruit-based dishes are Satvik.\n\nNote: If a recipe uses onion or garlic as optional ingredients, it can still be marked Satvik if those ingredients are skipped.",
        ta: "சாத்விக் உணவு பாரம்பரிய இந்து உணவு கொள்கைகளை பின்பற்றுகிறது:\n• வெங்காயம் இல்லை\n• பூண்டு இல்லை\n• இறைச்சி அல்லது முட்டை இல்லை\n• விரத நாட்கள் மற்றும் மத நிகழ்வுகளுக்கு ஏற்றது\n\nஎடுத்துக்காட்டு: சாதாரண பருப்பு, வெங்காயம்/பூண்டு இல்லாத கூட்டு சாத்விக் ஆகும்.",
      },
      {
        label: "Intensity",
        label_ta: "உணவின் தீவிரம்",
        en: "How heavy or filling is this dish?\n• Light — easy to digest, suitable for all ages (idli, rasam, kanji, fruit)\n• Medium — regular everyday meal (sambar rice, chapati with dal, dosa)\n• Heavy — rich, filling, takes longer to digest (biryani, halwa, paya, fried items)\n\nUse this to balance the week — not all meals should be Heavy.",
        ta: "இந்த உணவு எவ்வளவு கனமானது?\n• Light — எளிதில் செரிக்கும், எல்லா வயதினருக்கும் ஏற்றது (இட்லி, ரசம், கஞ்சி)\n• Medium — அன்றாட சாதாரண உணவு (சாம்பார் சாதம், சப்பாத்தி)\n• Heavy — கனமான, செரிக்க நேரம் ஆகும் (பிரியாணி, அல்வா, பாயா)\n\nவாரத்தை சமன்படுத்த இதை பயன்படுத்துங்கள் — அனைத்தும் Heavy ஆக இருக்க வேண்டாம்.",
      },
      {
        label: "Scalable",
        label_ta: "அளவு மாற்றம்",
        en: "Can this recipe be easily made for more or fewer people by adjusting ingredient quantities?\n• Yes (Scalable) — doubling ingredients gives the same result. Most curries, rice dishes, chutneys are scalable.\n• No (Not Scalable) — the recipe requires exact quantities. Some sweets like Mysore Pak or deep-fried snacks where oil temperature matters.\n\nFor most everyday Tamil Nadu dishes, this should be Yes.",
        ta: "பொருட்களின் அளவை மாற்றி இந்த சமையல் குறிப்பை அதிகமான அல்லது குறைவான நபர்களுக்கு எளிதாக செய்ய முடியுமா?\n• ஆம் — இரண்டு மடங்கு பொருட்கள் சேர்த்தால் அதே முடிவு கிடைக்கும். பெரும்பாலான குழம்பு, சாதம், சட்னி இப்படிப்பட்டவை.\n• இல்லை — சில இனிப்புகள் மற்றும் வறுத்த தின்பண்டங்களில் சரியான அளவு முக்கியம்.\n\nபெரும்பாலான தமிழ்நாடு வீட்டு சமையலுக்கு ஆம் என்று குறிக்கவும்.",
      },
      {
        label: "Regional Specific",
        label_ta: "பிராந்திய சிறப்பு",
        en: "Is this dish unique to a specific sub-region of Tamil Nadu?\n• Yes — dishes like Chettinad Kuzhambu, Tirunelveli Halwa, Kongunadu Kari Dosa are specific to their regions\n• No — dishes like Idli, Sambar, Rasam are eaten across all of Tamil Nadu\n\nThis helps the recommendation engine bring regional variety to the weekly plan.",
        ta: "இந்த உணவு தமிழ்நாட்டின் குறிப்பிட்ட பகுதிக்கு மட்டுமே உரியதா?\n• ஆம் — செட்டிநாடு குழம்பு, திருநெல்வேலி அல்வா, கொங்குநாடு கறி தோசை போன்றவை\n• இல்லை — இட்லி, சாம்பார், ரசம் போன்றவை தமிழ்நாடு முழுவதும் சாப்பிடப்படும்",
      },
      {
        label: "Optional Ingredients",
        label_ta: "விருப்பத்தேர்வு பொருட்கள்",
        en: "Some ingredients in a recipe can be skipped without significantly changing the dish.\n\nTap any ingredient to toggle between Required and Optional.\n\nCommon optional ingredients:\n• Onion — can be skipped for Satvik cooking\n• Garlic — can be skipped for Satvik cooking\n• Cashews — garnish, can be skipped\n• Green chilli — can reduce or skip based on spice preference\n\nThis helps the app suggest Satvik alternatives when needed.",
        ta: "சமையல் குறிப்பில் சில பொருட்களை தவிர்த்தாலும் உணவின் சுவை பெரிதாக மாறாது.\n\nஎந்த பொருளையும் தட்டி Required மற்றும் Optional இடையே மாற்றலாம்.\n\nபொதுவான விருப்பத்தேர்வு பொருட்கள்:\n• வெங்காயம் — சாத்விக் சமையலுக்கு தவிர்க்கலாம்\n• பூண்டு — சாத்விக் சமையலுக்கு தவிர்க்கலாம்\n• முந்திரி — அலங்காரத்திற்கு, தவிர்க்கலாம்",
      },
      {
        label: "YouTube Links",
        label_ta: "யூட்யூப் இணைப்புகள்",
        en: "Add up to 3 YouTube video links that show how to make this dish.\n\nGood videos to link:\n• Step-by-step cooking tutorial\n• Traditional preparation method\n• Regional variation of the dish\n\nHow to get the link: Open YouTube → find the video → copy the URL from the address bar → paste here.\n\nExample: https://www.youtube.com/watch?v=xxxxxxx",
        ta: "இந்த உணவை எப்படி செய்வது என்று காட்டும் 3 யூட்யூப் வீடியோ இணைப்புகளை சேர்க்கலாம்.\n\nநல்ல வீடியோக்கள்:\n• படிப்படியான சமையல் வழிகாட்டி\n• பாரம்பரிய செய்முறை\n• பிராந்திய வகை\n\nஇணைப்பு எப்படி பெறுவது: யூட்யூப் திறக்கவும் → வீடியோ தேடவும் → முகவரி பட்டியில் இருந்து URL நகலெடுக்கவும் → இங்கே ஒட்டவும்.",
      },
      {
        label: "Review Notes",
        label_ta: "மதிப்பாய்வு குறிப்புகள்",
        en: "Add notes for the platform admin about this recipe.\n\nWhen to add notes:\n• Image doesn't look like the dish — 'Image appears to be wrong dish'\n• Ingredients seem incorrect — 'Missing tamarind in this kuzhambu'\n• Regional classification unclear — 'Not sure if this is Chettinad or Kongunadu'\n• Both image attempts unsuccessful — 'Both images incorrect, needs manual image'\n\nNotes are visible only to platform admin and reviewers — not to end users.",
        ta: "இந்த சமையல் குறிப்பு பற்றி platform admin க்கு குறிப்புகள் சேர்க்கவும்.\n\nஎப்போது குறிப்புகள் சேர்க்க வேண்டும்:\n• படம் உணவை சரியாக காட்டவில்லை — 'படம் தவறான உணவை காட்டுகிறது'\n• பொருட்கள் தவறாக இருக்கலாம் — 'இந்த குழம்பில் புளி இல்லை'\n• பிராந்திய வகை தெளிவில்லை\n\nகுறிப்புகள் platform admin மற்றும் reviewers மட்டுமே பார்க்க முடியும்.",
      },
    ],
  },
];

export default function HelpScreen({ onBack }) {
  const [lang, setLang] = useState("en");
  const [openField, setOpenField] = useState(null);

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px", position: "sticky", top: 0, zIndex: 10 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <div onClick={onBack} style={{ color: C.mint, fontSize: 20, cursor: "pointer" }}>←</div>
          <div style={{ flex: 1 }}>
            <div style={{ color: C.mint, fontSize: 11, fontWeight: 500, letterSpacing: "0.05em" }}>LADLEFUL</div>
            <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500, marginTop: 2 }}>
              {lang === "en" ? "Help & Guide" : "உதவி & வழிகாட்டி"}
            </div>
          </div>
          {/* Language toggle */}
          <div style={{ display: "flex", gap: 4 }}>
            <div onClick={() => setLang("en")}
              style={{ padding: "5px 10px", borderRadius: 8, fontSize: 11, fontWeight: 500, cursor: "pointer", background: lang === "en" ? C.mint : "transparent", color: lang === "en" ? C.green : C.mint }}>
              EN
            </div>
            <div onClick={() => setLang("ta")}
              style={{ padding: "5px 10px", borderRadius: 8, fontSize: 11, fontWeight: 500, cursor: "pointer", background: lang === "ta" ? C.mint : "transparent", color: lang === "ta" ? C.green : C.mint }}>
              தமிழ்
            </div>
          </div>
        </div>
      </div>

      {/* Sections */}
      <div style={{ padding: "14px 14px 80px" }}>
        {SECTIONS.map(section => (
          <div key={section.id} style={{ marginBottom: 16 }}>

            {/* Section header */}
            <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "10px 0 8px" }}>
              <span style={{ fontSize: 18 }}>{section.icon}</span>
              <div>
                <div style={{ fontSize: 14, fontWeight: 600, color: C.green }}>{section.title}</div>
                <div style={{ fontSize: 11, color: C.muted }}>{section.title_ta}</div>
              </div>
            </div>

            {/* Fields */}
            {section.fields.map((field, idx) => (
              <div key={idx}
                style={{ background: C.card, borderRadius: 12, marginBottom: 8, border: `0.5px solid ${C.border}`, overflow: "hidden" }}>

                {/* Field header — tap to expand */}
                <div onClick={() => setOpenField(openField === `${section.id}-${idx}` ? null : `${section.id}-${idx}`)}
                  style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px 14px", cursor: "pointer" }}>
                  <div>
                    <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>{field.label}</div>
                    <div style={{ fontSize: 11, color: C.muted, marginTop: 2 }}>{field.label_ta}</div>
                  </div>
                  <div style={{ fontSize: 16, color: C.muted, transition: "transform 0.2s", transform: openField === `${section.id}-${idx}` ? "rotate(180deg)" : "rotate(0deg)" }}>
                    ›
                  </div>
                </div>

                {/* Field content */}
                {openField === `${section.id}-${idx}` && (
                  <div style={{ padding: "0 14px 14px", borderTop: `0.5px solid ${C.border}` }}>
                    <div style={{ fontSize: 12, color: C.text, lineHeight: 1.8, marginTop: 10, whiteSpace: "pre-line" }}>
                      {lang === "en" ? field.en : field.ta}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        ))}

        {/* Footer note */}
        <div style={{ background: "#E1F5EE", borderRadius: 12, padding: "12px 14px", border: `0.5px solid ${C.mint}` }}>
          <div style={{ fontSize: 12, color: "#085041", lineHeight: 1.6 }}>
            {lang === "en"
              ? "If you find any errors in the Tamil translations or help content, please add a note in the Review Notes field of that recipe so we can update it."
              : "தமிழ் மொழிபெயர்ப்பில் அல்லது உதவி உள்ளடக்கத்தில் ஏதேனும் தவறுகள் இருந்தால், அந்த சமையல் குறிப்பின் Review Notes பகுதியில் குறிப்பிடவும்."}
          </div>
        </div>
      </div>
    </div>
  );
}
