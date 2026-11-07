# Issue tracker: GitHub

Энэ repo-гийн issue болон spec-үүд GitHub issue хэлбэрээр байна. Бүх үйлдэлд `gh` CLI ашигла.

## Дүрэм

- **Issue үүсгэх**: `gh issue create --title "..." --body "..."`. Олон мөрт body-д heredoc ашигла.
- **Issue унших**: `gh issue view <number> --json number,title,body,labels,comments`.
- **Issue-ийн жагсаалт**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`, тохирох `--label` ба `--state` шүүлтүүртэй.
- **Issue-г эцэг issue-ийн sub-issue болгох**: `gh issue create --parent <parent> ...`, эсвэл дараа нь `gh issue edit <parent> --add-sub-issue <child>` (`gh` 2.94+). Хуучин `gh`: `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>` (database id, доорх **Хориг**-т байгаа шиг). Sub-issue байхгүй бол child-ийн body-гийн эхэнд `Part of #<parent>` гэж бич.
- **Хориг (blocking)**: GitHub-ийн **native issue dependency**, UI дээр харагддаг үндсэн хэлбэр. Edge нэмэх: `gh issue create --blocked-by <n>,<n> ...` эсвэл `gh issue edit <child> --add-blocked-by <blocker>` (`gh` 2.94+). Хуучин `gh`: `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, энд `<blocker-db-id>` бол blocker-ийн тоон **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`; `#number` эсвэл `node_id` _биш_). Dependency боломжгүй газар child-ийн body-гийн эхэнд `Blocked by: #<n>, #<n>` мөр бич. Бүх blocker нь хаагдвал ticket хоригоос гарна.
- **Нээлттэй blocker тоолох**: `gh api repos/<owner>/<repo>/issues/<n> --jq .issue_dependencies_summary.blocked_by` (зөвхөн нээлттэй blocker; 0 бол эхэлж болно). `gh issue view <n> --json blockedBy` хаагдсан blocker-уудыг ч жагсаадаг тул шүү: `--jq '[.blockedBy.nodes[] | select(.state == "OPEN")] | length'`.
- **Issue-д comment бичих**: `gh issue comment <number> --body "..."`
- **Label нэмэх / хасах**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Хаах**: эхлээд тайлбараа `gh issue comment <number> --body "..."`-ээр бичээд, дараа нь `gh issue close <number>`. Аль хэдийн хаагдсан issue дээр `gh issue close --comment` comment-ийг хаяад, 0 кодоор амжилттай гардаг.

Repo-г `git remote -v`-ээс тодорхойл; clone дотор ажиллахад `gh` үүнийг автоматаар хийдэг.

Issue-г зөвхөн хэрэглэгчийн өөрийн repo руу үүсгэ. Энэ skill-үүдийн ирсэн repo-г (энэ plugin-ий repo) хэрэглэгч өөрөө эзэмшдэггүй бол тэнд хэзээ ч issue үүсгэхгүй. Fork дотор `gh` upstream эцэг repo-г default болгож магадгүй тул session-ий анхны `gh issue create`-ээс өмнө `gh repo view --json nameWithOwner`-ээр зорилтот repo-г шалгаж, хэрэглэгчийнх биш бол түүнээр батлуул.

## Pull request-ийг ангиллын суваг болгох

**PR-ийг хүсэлт ирэх суваг гэж үзэх: үгүй.** _(Энэ repo гадны PR-ийг feature хүсэлт гэж үздэг бол `тийм` болго; `/angil` энэ тугийг уншина.)_

`тийм` үед PR-ууд issue-тэй ижил label, төлөвөөр, `gh pr`-ийн харгалзах командуудаар явна:

- **PR унших**: `gh pr view <number>`, дараа нь `gh pr view <number> --comments` (TTY-гүй үед `--comments` зөвхөн comment-уудыг хэвлэдэг, body-г биш), diff-д `gh pr diff <number>`.
- **Ангилах гадны PR-уудыг жагсаах**: `gh api --paginate 'repos/{owner}/{repo}/pulls?state=open' --jq '.[] | select(.author_association | IN("OWNER","MEMBER","COLLABORATOR") | not) | {number, title, author: .user.login, author_association, labels: [.labels[].name]}'`.
- **Comment / label / хаах**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub issue ба PR-д нэг дугаарлалт хэрэглэдэг тул зүгээр `#42` аль нь ч байж болно: `gh pr view 42`-оор шалгаад, болохгүй бол `gh issue view 42`.

## Skill "issue tracker-т нийтэл" гэвэл

GitHub issue үүсгэ.

## Skill "холбогдох ticket-ийг татаж ав" гэвэл

Дээрх **Issue унших**-ийн дагуу унш.

## `/zam-ol`-ийн үйлдлүүд

`/zam-ol` ашигладаг. **Map** (газрын зураг) бол нэг issue, түүний **child** issue-ууд нь ticket-үүд.

- **Map**: `zam-ol:map` label-тай нэг issue, body нь Тэмдэглэл / Гаргасан шийдвэрүүд / Одоохондоо тодорхойгүй (манан) хэсгүүдтэй. `gh issue create --label zam-ol:map`.
- **Child ticket**: map-тай GitHub sub-issue-гээр холбогдсон issue (**Issue-г эцэг issue-ийн sub-issue болгох**-ыг үз). Sub-issue идэвхгүй бол child-ийг map-ын body дахь task list-д нэмж, child-ийн body-гийн эхэнд `Part of #<map>` гэж бич. Label: `zam-ol:<type>` (`research`/`prototype`/`grilling`/`task`). Эзэмшсэний дараа ticket нь map-ыг жолоодож буй хүнд assign хийгдэнэ.
- **Хориг**: Дүрэм хэсгийн **Хориг (blocking)**-ийг үз.
- **Frontier-ийн query**: map-ын нээлттэй child-уудыг жагсаа (`gh issue list --state open`, map-ын sub-issue / task list-ээр хязгаарлана), нээлттэй blocker-тэй (**Нээлттэй blocker тоолох**-ыг, эсвэл `Blocked by` мөр дэх нээлттэй issue-г үз) эсвэл assignee-тэйг хас; map-ын дарааллаар эхнийх нь ялна.
- **Эзэмших (claim)**: `gh issue edit <n> --add-assignee @me`, session-ий анхны бичилт.
- **Шийдэх (resolve)**: `gh issue comment <n> --body "<answer>"`, дараа нь `gh issue close <n>`, тэгээд map-ын Гаргасан шийдвэрүүд хэсэгт context pointer (товчлол + холбоос) нэм.
