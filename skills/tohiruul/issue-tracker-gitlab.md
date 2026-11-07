# Issue tracker: GitLab

Энэ repo-гийн issue болон spec-үүд GitLab issue хэлбэрээр байна. Бүх үйлдэлд [`glab`](https://gitlab.com/gitlab-org/cli) CLI ашигла.

## Дүрэм

- **Issue үүсгэх**: `glab issue create --title "..." --description "..."`. Олон мөрт description-д heredoc ашигла. Editor нээхийн тулд `--description -` дамжуул.
- **Issue унших**: `glab issue view <number> --comments`. Машинд уншигдах гаралтад `-F json` ашигла.
- **Issue-ийн жагсаалт**: `glab issue list -O json`, тохирох `--label` шүүлтүүртэй.
- **Issue-д comment бичих**: `glab issue note <number> --message "..."`. GitLab comment-ийг "note" гэдэг.
- **Label нэмэх / хасах**: `glab issue update <number> --label "..."` / `--unlabel "..."`. Олон label-ийг таслалаар эсвэл flag-аа давтаж өгч болно.
- **Хаах**: `glab issue close <number>`. `glab issue close` хаах comment хүлээж авдаггүй тул эхлээд тайлбараа `glab issue note <number> --message "..."`-ээр бичээд, дараа нь хаа.
- **Merge request**: GitLab PR-ийг "merge request" гэдэг. `glab mr create`, `glab mr view`, `glab mr note` гэх мэт ашигла: `gh pr ...`-тэй ижил хэлбэр, `pr`-ийн оронд `mr`, `comment`/`--body`-гийн оронд `note`/`--message`.

Repo-г `git remote -v`-ээс тодорхойл; clone дотор ажиллахад `glab` үүнийг автоматаар хийдэг.

## Merge request-ийг ангиллын суваг болгох

**MR-ийг хүсэлт ирэх суваг гэж үзэх: үгүй.** _(Энэ repo гадны merge request-ийг feature хүсэлт гэж үздэг бол `тийм` болго; `/angil` энэ тугийг уншина.)_

`тийм` үед MR-ууд issue-тэй ижил label, төлөвөөр, `glab mr`-ийн харгалзах командуудаар явна:

- **MR унших**: `glab mr view <number> --comments`, diff-д `glab mr diff <number>`.
- **Ангилах гадны MR-уудыг жагсаах**: `glab mr list -O json`, тэгээд зохиогч нь project-ийн member/owner биш MR-уудыг л үлдээ (maintainer-ийн хийгдэж буй ажил биш, гадны хувь нэмэр оруулагчийн MR).
- **Comment / label / хаах**: `glab mr note`, `glab mr update --label`/`--unlabel`, `glab mr close`.

GitHub-ээс ялгаатай нь GitLab issue ба MR-ийг тусад нь дугаарладаг тул maintainer аль сувгийг хэлж байгааг мэдвэл `#42` хоёрдмол утгагүй.

## Skill "issue tracker-т нийтэл" гэвэл

GitLab issue үүсгэ.

## Skill "холбогдох ticket-ийг татаж ав" гэвэл

`glab issue view <number> --comments` ажиллуул.

## `/zam-ol`-ийн үйлдлүүд

`/zam-ol` ашигладаг. **Map** (газрын зураг) бол нэг issue, түүний **child** issue-ууд нь ticket-үүд.

- **Map**: `zam-ol:map` label-тай нэг issue, body нь Тэмдэглэл / Гаргасан шийдвэрүүд / Одоохондоо тодорхойгүй (манан) хэсгүүдтэй. `glab issue create --label zam-ol:map`. (Native epic-тэй GitLab tier дээр map-ыг epic-д хадгалж болно; label-тай issue хаана ч ажиллана.)
- **Child ticket**: description-ийнхээ эхэнд `Part of #<map>` бичсэн, map-тай холбогдсон (`glab issue create --linked-issues <map> --link-type relates_to`), `zam-ol:<type>` (`research`/`prototype`/`grilling`/`task`) label-тай issue. Эзэмшсэний дараа ticket нь map-ыг жолоодож буй хүнд assign хийгдэнэ.
- **Хориг (blocking)**: GitLab-ийн **native blocking link**, UI дээр харагддаг үндсэн хэлбэр. Note болгон `/blocked_by #<n>` quick action-аар нэм (`glab issue note <child> --message "/blocked_by #<blocker>"`). Native blocking link бол Premium/Ultimate-ийн боломж; үнэгүй tier дээр (эсвэл боломжгүй газар) description-ийн эхэнд `Blocked by: #<n>, #<n>` мөр бич. Бүх blocker нь хаагдвал ticket хоригоос гарна.
- **Frontier-ийн query**: map-ын child-уудыг `glab api projects/:id/issues/<map>/links`-ээр жагсааж, `zam-ol:<type>` label-тай нээлттэй issue-уудыг үлдээ; нээлттэй blocker-тэйг хас: нээлттэй issue руу заасан native `blocked_by` холбоос (`glab api projects/:id/issues/<child-iid>/links`), эсвэл `Blocked by` мөр дэх нээлттэй issue, эсвэл assignee; map-ын дарааллаар эхнийх нь ялна.
- **Эзэмших (claim)**: `glab issue update <n> --assignee @me`, session-ий анхны бичилт.
- **Шийдэх (resolve)**: `glab issue note <n> --message "<answer>"`, дараа нь `glab issue close <n>`, тэгээд map-ын Гаргасан шийдвэрүүд хэсэгт context pointer (товчлол + холбоос) нэм.
