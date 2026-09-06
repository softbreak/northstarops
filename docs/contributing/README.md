# NorthStarOps Katkı Rehberleri

Bu klasör, NorthStarOps'a katkı verirken karşılaşacağın ana adımları kısa ve uygulanabilir şekilde anlatır.

## Katkı akışı

1. [`/claim` ile Issue alma](claim-an-issue.md)
2. [Claim süresi dolarsa ne olur?](claim-timeout.md)
3. [Draft Pull Request açma](open-draft-pr.md)
4. [Changes requested sonrası düzeltme yapma](respond-to-changes-requested.md)
5. [PR onaylandıktan sonra ne olur?](after-approval.md)
6. [Merge sonrası süreç](after-merge.md)

## Issue durumları

Katılımcı olarak public Issue üzerinde şu durumları görürsün:

- `status: available` — claim edilebilir iş
- `status: claimed` — bir katılımcı tarafından alınmış iş
- `status: in-review` — Pull Request review sürecinde
- `status: done` — katkı tamamlanmış

## Temel kural

Bir Issue üzerinde çalışmaya başlamadan önce mutlaka `/claim` kullan.

Claim kabul edilmeden o Issue için çalışma başlatma veya Pull Request açma. Claim kabul edildikten sonra ilgili Issue altında sana sonraki adımı anlatan bir mesaj gösterilir.