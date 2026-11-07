---
name: tohiruul
description: "Энэ repo-г engineering skill-үүдэд тохируулна: issue tracker, triage label-ийн нэрс, domain doc-ийн бүтцийг бэлдэнэ. Бусад engineering skill-ийг анх ашиглахаас өмнө нэг удаа ажиллуул."
disable-model-invocation: true
---

# Тохируул

Engineering skill-үүдийн хүлээдэг repo тус бүрийн тохиргоог бэлд:

- **Issue tracker**: issue-ууд хаана байх (default нь GitHub; local markdown-ийг ч шууд дэмждэг)
- **Triage label**: ангиллын (triage) таван үндсэн үүрэгт хэрэглэх нэрс
- **Domain doc**: `GLOSSARY.md` ба ADR-ууд хаана байх, тэдгээрийг уншигч skill-үүдийн дүрэм

Энэ бол тогтмол script биш, prompt-оор ажилладаг skill. Судал, олсноо танилцуул, хэрэглэгчээр батлуул, тэгээд бич.

## Процесс

### 1. Судал

Одоогийн repo-гийн эхлэлийн байдлыг ойлгохын тулд хар. Байгаа бүхнийг уншиж, баримт дээр тулгуурла:

- `git remote -v` ба `.git/config`: энэ GitHub repo мөн үү? Аль нь?
- repo-гийн root дахь `AGENTS.md` ба `CLAUDE.md`: аль нэг нь байгаа юу? Аль нэгэнд нь `## Agent skills` хэсэг аль хэдийн бий юу?
- root дахь `GLOSSARY.md` ба `GLOSSARY-MAP.md`, мөн хуучин `CONTEXT.md` / `CONTEXT-MAP.md`. Хуучин файл байвал `GLOSSARY` нэр рүү нь `git mv` хийхийг санал болгож, `docs/agents/domain.md` доторх нэрсийг шинэчил.
- `docs/adr/` ба `src/*/docs/adr/` folder-ууд
- `docs/agents/`: энэ skill-ийн өмнөх үр дүн аль хэдийн бий юу?
- `.scratch/`: local-markdown issue tracker-ийн дүрэм аль хэдийн хэрэглэгдэж буйн шинж
- `angil` skill суусан уу? (энэ skill-ийн хажууд `angil` folder, эсвэл боломжит skill-үүдийн дунд `angil`.) Энэ нь B хэсэг ажиллах эсэхийг шийднэ.
- Monorepo-гийн шинж: `pnpm-workspace.yaml`, `package.json` дахь `workspaces` талбар, эсвэл өөрийн `src/`-тэй дүүрэн `packages/*`. Эдгээр нь зөвхөн жинхэнэ том, олон package-тэй repo-д байдаг; байхгүй бол single-context гэсэн үг, бараг бүх repo ийм.

### 2. Олсноо танилцуулж, асуу

Юу байгаа, юу дутуу байгааг хураангуйл. Дараа нь хэсгүүдийг дарааллаар нь яв. Нэг хэсэг, нэг хариулт, дараа нь дараагийнх.

Хэсэг бүрийг санал болгох хариултаар эхлүүл, ингэснээр хэрэглэгч нэг үгээр зөвшөөрч чадна. Сонголт үнэхээр салаалах үед л нэг мөр тайлбар өг; судалгаагаар аль хэдийн шийдэгдсэн хэсгийг бүхэлд нь алгас (`angil` суугаагүй бол B хэсэг, monorepo байхгүй бол C хэсэг).

**A хэсэг: Issue tracker.**

> Тайлбар: "Issue tracker" бол энэ repo-гийн issue-ууд байдаг газар. `ticket-bolgo`, `angil`, `spec-bolgo` зэрэг skill-үүд тэндээс уншиж, тэнд бичдэг. Тэд `gh issue create` дуудах уу, `.scratch/` доор markdown файл бичих үү, эсвэл чиний тайлбарласан өөр арга уу гэдгийг мэдэх хэрэгтэй. Энэ repo-гийн ажлаа үнэхээр хянадаг газраа сонго.

Default байр суурь: эдгээр skill GitHub-д зориулж бүтээгдсэн. `git remote` GitHub руу заасан бол түүнийг санал болго. `git remote` GitLab руу (`gitlab.com` эсвэл өөрийн host) заасан бол GitLab-ийг санал болго. Үгүй бол (эсвэл хэрэглэгч өөрөөр хүсвэл) дараахыг санал болго:

- **GitHub**: issue-ууд repo-гийн GitHub Issues-д байна (`gh` CLI ашиглана)
- **GitLab**: issue-ууд repo-гийн GitLab Issues-д байна ([`glab`](https://gitlab.com/gitlab-org/cli) CLI ашиглана)
- **Local markdown**: issue-ууд энэ repo-гийн `.scratch/<feature>/` доор файл болж байна (ганцаараа хийж буй төсөл эсвэл remote-гүй repo-д тохиромжтой)
- **Бусад** (Jira, Linear гэх мэт): хэрэглэгчээс ажлын урсгалаа нэг догол мөрөөр тайлбарлахыг хүс; skill үүнийг чөлөөт текстээр тэмдэглэнэ

Сонголтоо `docs/agents/issue-tracker.md`-д тэмдэглэ. GitHub ба GitLab-ийн загварт "PR-ийг хүсэлт ирэх суваг гэж үзэх" туг бий, default нь **унтраалттай**. Унтраалттай нь үлдээж, энэ тухай асуухгүй: гадны PR-ийг ангиллын дараалалд оруулахыг хүссэн хэрэглэгч дараа нь файл дотор тугаа өөрөө сольж болно.

GitHub эсвэл GitLab tracker-т хүрч болох repo хэрэгтэй. Хэрэглэгч аль нэгийг сонгосон ч тэр host руу заасан `git remote` байхгүй бол цааш явахаасаа өмнө repo-гийн URL-ийг түүнээс авч холбо (шаардлагатай бол `git init`, `git remote add origin <url>`). Энэ folder дотроос `gh repo view` / `glab repo view` project-ийг хэвлэвэл дууссан; хэвлэж чадахгүй бол зогсоод, юу дутуу байгааг хэрэглэгчид хэл.

**B хэсэг: Triage label-ийн нэрс.** `angil` skill суугаагүй бол (судалгаагаар мэдсэн) энэ хэсгийг бүхэлд нь алгас: суугаагүй skill-д label хэрэггүй.

Суусан бол яг нэг асуулт асуу:

> Default triage label-уудыг хэвээр нь үлдээх үү? (санал болгох нь: **тийм**)

Default нь таван үндсэн үүрэг, label бүрийн нэр нь үүргийнхээ нэртэй ижил: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. **Тийм** гэвэл хэвээр нь бич. Хэрэглэгч үгүй гэвэл л, ихэвчлэн tracker нь өөр нэр хэрэглэдэг учраас (жишээ нь `needs-triage`-ийн оронд `bug:triage`), өөрчлөлтүүдийг цуглуул, ингэснээр `angil` давхар label үүсгэхгүй, байгаа label-уудыг хэрэглэнэ.

**C хэсэг: Domain doc.** Default нь **single-context** (repo-гийн root-д нэг `GLOSSARY.md` + `docs/adr/`). Бараг бүх repo-д тохирно; асуулгүй бич.

**Multi-context**-ийг (root дахь `GLOSSARY-MAP.md` нь context бүрийн `GLOSSARY.md` руу заана) зөвхөн судалгаагаар monorepo-гийн шинж олдсон үед санал болго. Тэгээд аль бүтцийг хүсэж байгааг батлуул.

### 3. Батлуулж, засуул

Хэрэглэгчид дараахын ноорогийг харуул:

- `CLAUDE.md` / `AGENTS.md`-ийн засагдах нэгэнд нэмэх `## Agent skills` хэсэг (аль файлыг сонгохыг 4-р алхмаас үз)
- `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, `docs/agents/triage-labels.md`-ийн агуулга (сүүлчийнх нь зөвхөн `angil` суусан үед)

Бичихээсээ өмнө засах боломж өг.

### 4. Бич

**Засах файлаа сонго:**

- `CLAUDE.md` байвал түүнийг зас.
- Үгүй бөгөөд `AGENTS.md` байвал түүнийг зас.
- Аль нь ч байхгүй бол алийг нь үүсгэхийг хэрэглэгчээс асуу; түүний өмнөөс бүү сонго.

Үргэлж байгаа файлаа зас: `CLAUDE.md` байхад `AGENTS.md` үүсгэхгүй (эсрэгээрээ ч мөн адил).

Сонгосон файлд `## Agent skills` хэсэг аль хэдийн байвал давхардуулж нэмэхгүй, байгаа газарт нь агуулгыг шинэчил. Эргэн тойрны хэсгүүдэд хэрэглэгчийн хийсэн засварыг хэвээр нь үлдээ.

Блок:

```markdown
## Agent skills

### Issue tracker

[issue-ууд хаана хянагддаг тухай нэг мөр]. `docs/agents/issue-tracker.md`-г үз.

### Triage labels

[label-ийн нэрсийн тухай нэг мөр]. `docs/agents/triage-labels.md`-г үз.

### Domain docs

[бүтцийн тухай нэг мөр: "single-context" эсвэл "multi-context"]. `docs/agents/domain.md`-г үз.
```

`### Triage labels` дэд блок болон `docs/agents/triage-labels.md`-г зөвхөн `angil` суусан бөгөөд B хэсэг ажилласан үед оруул. Үгүй бол хоёуланг нь орхи.

B хэсэг GitHub эсвэл GitLab дээр ажилласан бол tracker-т байхгүй тохируулсан label бүрийг үүсгэ (`gh label create` / `glab label create`).

Дараа нь энэ skill-ийн folder дахь загваруудаас эхлэн doc файлуудыг бич:

- [issue-tracker-github.md](./issue-tracker-github.md): GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md): GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md): local-markdown issue tracker
- [triage-labels.md](./triage-labels.md): label-ийн харгалзаа (зөвхөн `angil` суусан бол)
- [domain.md](./domain.md): domain doc уншигчийн дүрэм + бүтэц

"Бусад" issue tracker-т `docs/agents/issue-tracker.md`-г хэрэглэгчийн тайлбараас шинээр бич.

### 5. Дууслаа

Тохиргоо дууссан, аль engineering skill-үүд эдгээр файлаас уншдаг болсныг хэрэглэгчид хэл. `docs/agents/*.md`-г дараа нь шууд засаж болно гэдгийг дурд; issue tracker солих эсвэл тэгээс эхлэх хүсэлтэй бол л энэ skill-ийг дахин ажиллуулна.
