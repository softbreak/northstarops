# NorthStarOps Katkı Rehberleri

Bu klasör, NorthStarOps'a katkı verirken karşılaşacağın ana adımları kısa ve uygulanabilir şekilde anlatır.

## Başlamadan önce

İlk katkından önce [Issue üzerinde çalışma kurallarını](issue-rules.md) ve [Issue nasıl okunur?](issue-guide.md) rehberini oku. Amaç, senden beklenen işi hızlıca anlamanı ve aynı proje üzerinde çalışan diğer katılımcılarla çakışmadan ilerlemeni sağlamaktır.

## Katkı akışı

1. [Issue üzerinde çalışma kuralları](issue-rules.md)
2. [Issue nasıl okunur?](issue-guide.md)
3. [`/claim` ile Issue alma](claim-an-issue.md)
4. [Claim süresi dolarsa ne olur?](claim-timeout.md)
5. [Draft Pull Request açma](open-draft-pr.md)
6. [Changes requested sonrası düzeltme yapma](respond-to-changes-requested.md)
7. [PR onaylandıktan sonra ne olur?](after-approval.md)
8. [Merge sonrası süreç](after-merge.md)

## Issue durumları

Katılımcı olarak public Issue üzerinde şu durumları görürsün:

- `status: available` — claim edilebilir iş
- `status: claimed` — bir katılımcı tarafından alınmış iş
- `status: in-review` — Pull Request review sürecinde
- `status: done` — katkı tamamlanmış

## Temel kural

Bir Issue üzerinde çalışmaya başlamadan önce mutlaka `/claim` kullan.

Claim kabul edilmeden o Issue için çalışma başlatma veya Pull Request açma. Claim kabul edildikten sonra ilgili Issue altında sana sonraki adımı anlatan bir mesaj gösterilir.