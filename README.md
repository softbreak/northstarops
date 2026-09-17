# NorthStarOps

NorthStarOps, gerçek bir iş akışını küçük ve doğrulanabilir katkılar üzerinden birlikte geliştirdiğimiz açık kaynak çalışma alanıdır.

Bu repository’de işler GitHub Issue’ları üzerinden ilerler.

## Katılmak istiyorsan

Önce katkı akışını oku:

👉 [Katkı Rehberi](docs/contributing/README.md)

Ardından çalışılabilir Issue’ları görüntüle:

👉 [Available Issues](https://github.com/softbreak/northstarops/issues?q=is%3Aissue+is%3Aopen+label%3A%22status%3A+available%22)

## Temel akış

```text
Available
→ /claim
→ Claimed
→ Draft Pull Request
→ In Review
→ Done
```

Bir Issue’yu claim etmeden çalışmaya başlama.

Claim kabul edildikten sonra 24 saat içinde ilgili Issue’ya bağlı bir Draft Pull Request açılması beklenir.

## Yerel geliştirme

.NET, SQL Server ve veritabanı kurulumu için:

👉 [Local Development](docs/local-development.md)

## Katkı kuralları

- Aynı anda yalnızca 1 aktif Issue claim et.
- Issue içindeki `Allowed scope` dışına çıkma.
- `Out of scope` alanlarını değiştirme.
- Her PR yalnızca 1 Issue ile ilişkili olmalı.
- Review sırasında aynı branch ve aynı PR üzerinden devam et.
- Merge işlemini maintainer gerçekleştirir.

Detaylı süreç:

👉 [NorthStarOps Katkı Rehberleri](docs/contributing/README.md)
