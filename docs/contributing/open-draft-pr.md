# Draft Pull Request Açma

Claim kabul edildikten sonra **24 saat içinde** ilgili Issue için bir Draft Pull Request açmalısın.

## Önerilen akış

1. Public repoyu fork et.
2. Fork'unu clone et.
3. `main` üzerinden yeni bir branch oluştur.
4. Issue kapsamındaki değişikliği yap.
5. Testleri çalıştır.
6. Commit ve push yap.
7. Public `softbreak/northstarops` reposuna Draft Pull Request aç.

## Branch adı

Şu formatı kullan:

```text
feature/<issue-number>-<short-name>
```

Örnek:

```text
feature/12-product-readiness
```

## Issue bağlantısı

PR açıklamasında ilgili Issue'yu kapatma anahtar sözcüğüyle bağla:

```text
Closes #12
```

Her PR tam olarak **1 Issue** ile ilişkilendirilmelidir.

## Draft PR kabul edildiğinde

- Issue `status: in-review` durumuna geçer.
- Private proje kaydı `In review` olur.
- Review süreci başlar.

## Dikkat

Normal contributor Issue'larında yalnız Issue kapsamındaki dosyaları değiştir. Özellikle solution, governance, generated persistence ve database dosyalarına Issue açıkça istemiyorsa dokunma.
