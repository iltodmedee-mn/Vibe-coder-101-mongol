---
name: spec-heregjuul
description: "/spec-bolgo ба /ticket-bolgo-гийн үр дүнг кодоор хэрэгжүүлнэ."
disable-model-invocation: true
---

Чамд spec өгөгдсөн. Энэ spec-д түүнийг хэрхэн хэрэгжүүлэхийг тайлбарласан ticket-үүд холбогдсон байх ёстой.

Issue tracker чамд өгөгдсөн байх ёстой. Үгүй бол хэрэглэгчид `/tohiruul` ажиллуулахыг хэл.

Зорилго: spec бүхэлдээ нэг **integration branch** (бүх ажлыг нэгтгэдэг branch) дээр хэрэгжиж, ticket бүр issue tracker-ийн ажил хаадаг аргаар шийдэгдсэн байх.

Ticket-үүд бол алхмын жагсаалт биш. Тэд хоорондоо хориглох (blocking) холбоотой **task graph** (даалгаврын граф). Тиймээс шууд авч болох ticket-үүдийн **frontier** (одоо эхлүүлж болох ticket-үүдийн хил) үргэлж байна.

Subagent бүрийг шинэ context window-тойгоор эхлүүл.

Subagent руу болон subagent-аас ирэх харилцаа цөөн үгтэй байх ёстой. Голчлон **context pointer**-оор харилц: spec, ticket, судалгааны тэмдэглэл, өмнөх commit-ууд руу заа. Pointer-оор аль хэдийн олдох мэдээллийг давхардуулж бүү бич.

**Implementer subagent**-уудыг аль болох зэрэг ажиллуулахын тулд боломжтой бол background-д ажиллуул.

## Алхмууд

1. Spec ба ticket-үүдийг уншиж task graph-ийг ойлго.

2. (заавал биш) Ticket-үүдэд шаардлагатай судалгааг (кодын холбогдох файлууд эсвэл гадны documentation) **exploration subagent**-аар хийлгэ. Exploration subagent файл хадгалж чаддаг эсэхийг шалга: markdown тэмдэглэлээ repo-гоос гадна, дараагийн бүх subagent хандаж чадах folder-т хадгална. Ингэснээр **implementer subagent**-ууд судалгаа биш, хэрэгжүүлэлтэд төвлөрнө.

3. Integration branch-ийг үүсгэ. Issue tracker ажлыг PR-аар хаадаг эсвэл хэрэглэгч хүсвэл 5-р алхмын анхны merge-ийн дараа draft PR нээ (main-ээс урагш commit-гүй branch-аар PR нээж чадахгүй), түүнийг spec ба ticket-үүдийг хаадаг гэж тэмдэглэ.

4. Ticket бүрт шинэ **implementer subagent** ашигла, тус бүр өөрийн worktree, өөрийн branch дээр. Implementer subagent бүр:
   - ажил эхлэхээсээ өмнө worktree нь integration branch дээр суурилсан эсэхийг шалгаж, үгүй бол түүн дээр reset хийнэ;
   - ticket-ийг бүтээхдээ Skill tool-оор `test-ehleed`-ийг дуудна;
   - зөвхөн ticket-д хэрэгтэй кодыг өөрчилж, бусад ажиллаж байгаа хэсэгт хүрэхгүй;
   - дууссанаа мэдэгдэхээсээ өмнө integration branch-ийн tip-ийг (хамгийн сүүлийн commit) өөрийн branch руу merge хийнэ.

5. **Implementer subagent** дуусмагц түүний ажлыг **merger subagent**-аар integration branch руу merge хийлгэ.

6. Үүнээс болж авах боломжтой ticket-үүдийн **frontier** өөрчлөгдвөл шинэ ticket-үүд дээр нэмэлт **implementer subagent**-ууд эхлүүл. Ингэснээр аль болох зэрэг ажиллана.

7. Бүх ticket дууссаны дараа integration branch дээр Skill tool-оор `kod-hyana`-г дууд. Code review-ийн илрүүлсэн бүх асуудлыг нэг шинэ **implementer subagent**-аар засуул.

8. Draft PR байгаа бол review-д бэлэн гэж тэмдэглэ. Үгүй бол ticket бүрийг issue tracker-ийн ажил хаадаг аргаар шийдэж, integration branch-ийг мэдэгд. Аль ч тохиолдолд хэрэглэгчид юу өөрчлөгдсөн, үр дүнг яаж туршиж үзэхийг товч хэл.

9. **Implementer subagent**-уудын бүх worktree-г цэвэрлэ.
