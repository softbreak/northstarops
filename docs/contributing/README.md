# NorthStarOps Katkı Yaşam Döngüsü Rehberleri

Bu klasör, NorthStarOps katkı sürecinde karşılaşacağın her ana adım için kısa ve uygulanabilir rehberler içerir.

## Akış

1. [`/claim` ile Issue alma](claim-an-issue.md)
2. [Claim süresi dolarsa ne olur?](claim-timeout.md)
3. [Draft Pull Request açma](open-draft-pr.md)
4. [Changes requested sonrası düzeltme yapma](respond-to-changes-requested.md)
5. [PR onaylandıktan sonra ne olur?](after-approval.md)
6. [Merge sonrası süreç](after-merge.md)

## Temel kural

Her Issue tek bir katkı akışı üzerinden ilerler:

`Available → Claimed → In review → Done`

Public Issue label karşılıkları:

- `status: available`
- `status: claimed`
- `status: in-review`
- `status: done`

Bir Issue üzerinde çalışmaya başlamadan önce mutlaka `/claim` kullan. Claim kabul edilmeden Pull Request açma.
