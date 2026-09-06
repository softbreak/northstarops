# NorthStarOps Katkı Rehberleri

Bu klasör, NorthStarOps'a katkı verirken izleyeceğin akışı kısa ve uygulanabilir şekilde anlatır.

## Katkı akışı

1. [Issue üzerinde çalışma kuralları](issue-rules.md)
2. [Issue nasıl okunur?](issue-guide.md)
3. [`/claim` ile Issue alma](claim-an-issue.md)
4. [Çalışma ortamını hazırlama](prepare-workspace.md)
5. Issue kapsamındaki değişikliği yapma ve [commit/push](commit-and-push.md)
6. [Draft Pull Request açma ve Ready for review](open-draft-pr.md)
7. [Changes requested sonrası düzeltme yapma](respond-to-changes-requested.md)
8. [PR onaylandıktan sonra ne olur?](after-approval.md)
9. [Merge sonrası süreç](after-merge.md)

Claim süresi dolarsa [claim timeout rehberine](claim-timeout.md) bak.

## Issue durumları

Public Issue üzerinde şu durumları görürsün:

- `status: available` — claim edilebilir iş
- `status: claimed` — bir katılımcı tarafından alınmış iş
- `status: in-review` — katkı review aşamasında
- `status: done` — katkı tamamlanmış

## Temel kurallar

- Yalnızca `status: available` Issue üzerinde `/claim` kullan.
- Claim kabul edilmeden çalışma başlatma.
- Aynı anda yalnızca 1 aktif claim taşı.
- Claim sonrası 24 saat içinde Draft PR aç.
- Issue kapsamının dışına çıkma.
- Review düzeltmelerini aynı branch ve aynı PR üzerinden yap.

Her lifecycle adımında ilgili Issue altında sonraki adımı anlatan bir mesaj gösterilir.