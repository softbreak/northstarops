# `/claim` ile Issue Alma

Bir Issue üzerinde çalışmaya başlamadan önce Issue'nun `status: available` label'ına sahip olduğundan emin ol.

## Nasıl claim yapılır?

İlgili Issue'nun yorum alanına yalnızca şu komutu yaz:

```text
/claim
```

Komut kabul edilirse:

- Issue sana assign edilir.
- `status: available` kaldırılır.
- `status: claimed` eklenir.
- Private proje kaydı `Claimed` durumuna geçer.
- 24 saatlik Draft PR süren başlar.

## Önemli kurallar

- Aynı anda yalnızca **1 aktif claim** taşıyabilirsin.
- Başka bir katılımcı tarafından claim edilmiş Issue üzerinde çalışmaya başlama.
- Claim kabul edilmeden branch veya Pull Request açma.
- Claim kabul edildikten sonra **24 saat içinde** ilgili Issue'ya bağlı bir Draft Pull Request açmalısın.

## Sonraki adım

Claim kabul edildiyse [Draft Pull Request açma rehberine](open-draft-pr.md) geç.
