# HTML тайлангийн формат

Архитектурын хяналтыг үйлдлийн системийн түр folder-т байх нэг бие даасан HTML файл болгож гаргана. Tailwind ба Mermaid хоёулаа CDN-ээс ирнэ. Mermaid граф хэлбэрийн диаграммыг найдвартай зурдаг; гараар хийсэн div ба inline SVG илүү сэтгүүлийн маягийн дүрслэлийг (масс диаграмм, хөндлөн огтлол) зурна. Хоёуланг холь: бүгдийг Mermaid-ээр зурвал нэгэн хэвийн харагдаж эхэлнэ.

## Scaffold

```html
<!doctype html>
<html lang="mn">
  <head>
    <meta charset="utf-8" />
    <title>{{repo name}}-ийн архитектурын хяналт</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* Tailwind цэвэрхэн шийдэж чаддаггүй зүйлст зориулсан жижиг нэмэлт давхарга:
         тасархай seam шугам, гараар зурсан мэт сумны үзүүр гэх мэт. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Repo-гийн нэр, огноо, мөн товч тайлбар: бүтэн хүрээтэй хайрцаг = module, тасархай шугам = seam, улаан сум = нэвчилт, зузаан бараан хайрцаг = deep module. Оршил догол мөр бичихгүй. Шууд нэр дэвшигчид рүү ор.

## Нэр дэвшигчийн карт

Гол ачааг диаграмм үүрнэ. Текст нь цөөн, энгийн, нэр томъёог (`/kod-zagvar` skill-ийнх) ёс төдий тайлбаргүй хэрэглэнэ.

Нэр дэвшигч бүр нэг `<article>`:

- **Гарчиг**: богино, гүнзгийрүүлэлтийг нэрлэнэ (жишээ нь "Order intake pipeline-ийг нэг module болгох").
- **Badge-ийн мөр**: зөвлөмжийн хүч (`Хүчтэй` = emerald, `Судлах нь зүйтэй` = amber, `Таамаг` = slate), дээр нь хамаарлын ангиллын шошго (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Файлууд**: monospace жагсаалт, `font-mono text-sm`.
- **Өмнө / Дараах диаграмм**: гол хэсэг. Хоёр багана, зэрэгцээ. Доорх хэв маягуудыг үз.
- **Асуудал**: нэг өгүүлбэр. Юу өвдөж байна.
- **Шийдэл**: нэг өгүүлбэр. Юу өөрчлөгдөнө.
- **Ашиг**: bullet, тус бүр ≤6 үг. Жишээ нь "Test нэг interface-ийг шалгана", "Pricing логик нэвчихээ болино", "4 shallow wrapper устна".
- **ADR-ийн анхааруулга** (хамаарах бол): amber өнгөтэй хайрцагт нэг мөр.

Тайлбарын догол мөр бичихгүй. Диаграммыг ойлгоход догол мөр хэрэгтэй бол диаграммаа дахин зур.

## Диаграммын хэв маяг

Нэр дэвшигчид тохирох хэв маягийг сонго. Холь. Бүх диаграммыг ижил харагдуулж болохгүй. Олон янз байх нь зорилгын нэг хэсэг.

### Mermaid граф (хамаарал / call flow-ийн үндсэн хэрэгсэл)

Гол санаа нь "X нь Y-г, Y нь Z-г дууддаг, энэ замбараагүйг хар" бол Mermaid `flowchart` эсвэл `graph` хэрэглэ. Гэнэт унасан юм шиг харагдуулахгүйн тулд Tailwind-ийн загвартай карт дотор боо. Нэвчилтийн ирмэгийг улаан, deep module-ийг бараан болгохдоо classDef хэрэглэ. Sequence диаграмм "өмнө нь 6 удаа нааш цааш, одоо 1" гэдгийг харуулахад сайн.

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### Гараар хийсэн хайрцаг, сум (Mermaid-ийн байрлал саад болох үед)

Module-уудыг хүрээ, шошготой `<div>` болго. Сумыг relative контейнер дээр absolute байрласан inline SVG `<line>` эсвэл `<path>` болго. "Дараах" диаграммыг дотоод хэсгүүд нь саарал болсон, нэг зузаан хүрээтэй deep module шиг харагдуулах гэвэл үүнийг сонго, учир нь Mermaid тийм жинтэй зурдаггүй.

### Хөндлөн огтлол (давхарласан shallow байдалд тохиромжтой)

Дуудлагын дамждаг давхаргуудыг харуулахын тулд хэвтээ туузуудыг (`h-12 border-l-4`) давхарлан тавь. Өмнө: юу ч хийдэггүй 6 нимгэн давхарга. Дараа: нэгтгэсэн үүргээр шошголсон 1 зузаан тууз.

### Масс диаграмм ("interface нь implementation-тэйгээ адил өргөн" үед тохиромжтой)

Module бүрт хоёр тэгш өнцөгт: нэг нь interface-ийн гадаргуу, нөгөө нь implementation. Өмнө: interface-ийн тэгш өнцөгт implementation-ийнхтэй бараг адил өндөр (shallow). Дараа: interface-ийнх намхан, implementation-ийнх өндөр (deep).

### Call graph-ийг хумих

Өмнө: function-уудын дуудлагын мод, давхарласан хайрцаг хэлбэрээр. Дараа: тэр мод нэг хайрцагт хумигдаж, одоо дотоод болсон дуудлагууд нь дотор нь бүдэг харагдана.

## Загварын зөвлөмж

- Корпорацийн dashboard биш, сэтгүүлийн маягтай. Чөлөөтэй зай. Гарчигт serif үсэг хэрэглэж болно (`font-serif` stone/slate-тэй сайн зохицдог).
- Өнгийг гамтай хэрэглэ: нэг гол өнгө (emerald эсвэл indigo), дээр нь нэвчилтэд улаан, анхааруулгад amber.
- Өмнө/дараахыг гүйлгэхгүйгээр зэрэгцээ харуулахын тулд диаграммыг ~320px өндөртэй байлга.
- Диаграмм доторх module-ийн шошгонд `text-xs uppercase tracking-wider` хэрэглэ, тэгвэл UI биш, схем шиг уншигдана.
- Ганц script нь Tailwind CDN ба Mermaid ESM import. Үлдсэн тайлан статик: апп-ын код байхгүй, Mermaid-ийн өөрийнх нь зурахаас өөр interactivity байхгүй.

## Шилдэг зөвлөмжийн хэсэг

Нэг том карт. Нэр дэвшигчийн нэр, яагаад гэдэг нэг өгүүлбэр, түүний карт руу заах anchor холбоос. Тэгээд л болоо.

## Өнгө аяс

Энгийн Монгол хэлээр, товч, гэхдээ архитектурын нэр үг, үйл үгс `/kod-zagvar` skill-ээс шууд ирнэ. Товч байх нь нэр томъёоноос холдох шалтаг биш.

**Яг хэрэглэ:** module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

**Хэзээ ч бүү соль:** component, service, unit (module-ийн оронд) · API, signature (interface-ийн оронд) · boundary, хил (seam-ийн оронд) · layer, wrapper, давхарга (module гэж хэлэх гэж байгаа бол module-ийн оронд).

**Тохирох өгүүлбэрийн жишээ:**

- "Order intake module shallow: interface нь implementation-тэйгээ бараг адил."
- "Pricing seam-ийг давж нэвчиж байна."
- "Гүнзгийрүүл: нэг interface, test хийх нэг газар."
- "Хоёр adapter seam-ийг зөвтгөнө: prod-д HTTP, test-д in-memory."

**Ашгийн bullet-ууд** ашгийг нэр томъёогоор нэрлэнэ: *"locality: bug-ууд нэг module-д төвлөрнө"*, *"leverage: нэг interface, N дуудах газар"*, *"interface жижгэрнэ; implementation wrapper-уудыг шингээнэ"*. *"Засварлахад хялбар"* эсвэл *"цэвэрхэн код"* гэж бүү бич, учир нь эдгээр нь нэр томъёонд байхгүй, байр эзлэх үнэ цэнгүй.

Тээнэгэлзэхгүй, хоосон оршилгүй, "дурдах нь зүйтэй…" гэхгүй. Өгүүлбэр bullet болж чадах бол bullet болго. Bullet-ийг хасаж болох бол хас. Нэр томъёо `/kod-zagvar`-ийн жагсаалтад байхгүй бол шинээр зохиохоосоо өмнө жагсаалтад байгаа нэгийг хай.
