# Issue tracker: Local Markdown

Энэ repo-гийн issue болон spec-үүд `.scratch/` доторх markdown файл хэлбэрээр байна.

## Дүрэм

- Нэг feature-т нэг folder: `.scratch/<feature-slug>/`
- Spec нь `.scratch/<feature-slug>/spec.md`
- Хэрэгжүүлэх issue-ууд нь ticket бүрт нэг файл: `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, `01`-ээс дугаарлана; бүх ticket-ийг нэг файлд нэгтгэхгүй
- Ангиллын төлөвийг issue файл бүрийн эхэнд ойрхон `Status:` мөрөөр тэмдэглэнэ (үүргийн нэрсийг `triage-labels.md`-ээс үз)
- Comment болон ярианы түүх файлын төгсгөлд `## Comments` гарчгийн доор нэмэгдэнэ

## Skill "issue tracker-т нийтэл" гэвэл

`.scratch/<feature-slug>/` доор шинэ файл үүсгэ (folder байхгүй бол үүсгэнэ).

## Skill "холбогдох ticket-ийг татаж ав" гэвэл

Заасан зам дахь файлыг унш. Хэрэглэгч ихэвчлэн зам эсвэл issue-ийн дугаарыг шууд өгнө.

## `/zam-ol`-ийн үйлдлүүд

`/zam-ol` ашигладаг. **Map** (газрын зураг) бол нэг файл, ticket бүрт нэг **child** файлтай.

- **Map**: `.scratch/<effort>/map.md` (Тэмдэглэл / Гаргасан шийдвэрүүд / Одоохондоо тодорхойгүй (манан) хэсгүүдтэй body).
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, `01`-ээс дугаарлана, асуулт нь body-д. `Type:` мөр ticket-ийн төрлийг (`research`/`prototype`/`grilling`/`task`), `Status:` мөр `claimed`/`resolved`-ийг тэмдэглэнэ.
- **Хориг (blocking)**: эхэнд ойрхон `Blocked by: NN, NN` мөр. Жагсаасан бүх файл `resolved` болвол ticket хоригоос гарна.
- **Frontier**: `.scratch/<effort>/issues/`-ээс нээлттэй, хоригоос гарсан, эзэмшигдээгүй файлуудыг хай; дугаараар эхнийх нь ялна.
- **Эзэмших (claim)**: ямар ч ажил эхлэхээс өмнө `Status: claimed` болгоод хадгал.
- **Шийдэх (resolve)**: хариултыг `## Answer` гарчгийн доор нэмж, `Status: resolved` болго, тэгээд `map.md`-ийн Гаргасан шийдвэрүүд хэсэгт context pointer (товчлол + холбоос) нэм.
