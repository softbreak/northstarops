# Draft Pull Request Açma

Claim kabul edildikten sonra **24 saat içinde** ilgili Issue için bir Draft Pull Request açmalısın.

## Önerilen akış

1. Public repoyu fork et.
2. Fork'unu clone et.
3. `main` üzerinden yeni bir branch oluştur.
4. Issue kapsamındaki değişikliği yap.
5. Testleri çalıştır.
6. Commit ve push yap.
7. `softbreak/northstarops` reposuna Draft Pull Request aç.

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
- Review süreci başlar.
- Issue altında Draft PR'ın kabul edildiğini ve sıradaki adımı açıklayan bir mesaj gösterilir.

## Dikkat

Yalnızca Issue kapsamında istenen dosyaları değiştir. Issue açıkça istemiyorsa solution dosyalarına, `.github/**` altındaki repository otomasyon/configuration dosyalarına, generated persistence dosyalarına veya `database/**` altındaki dosyalara dokunma.