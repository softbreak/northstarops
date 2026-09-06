# Issue Nasıl Okunur?

NorthStarOps'ta her Issue mümkün olduğunca küçük, doğrulanabilir ve sınırları belli bir işi tarif eder.

Bir Issue'yu claim etmeden önce aşağıdaki bölümleri sırayla oku. Amaç, senden beklenen işi hızlıca anlaman ve gereksiz kapsam büyümesinden kaçınmandır.

## 1. Amaç

Bu bölüm işin neden yapıldığını açıklar.

Burada teknik çözümden önce problemin bağlamını anlamaya çalış.

Kendine şu soruyu sor:

> Bu değişiklik hangi ihtiyacı karşılıyor?

## 2. Beklenen sonuç

İş tamamlandığında sistemde gözlemlenebilir olarak neyin değişmiş olması gerektiğini anlatır.

Bu bölüm sana "ne üretmeliyim?" sorusunun cevabını verir.

Çözüm biçimini gereksiz yere genişletme; önce burada tarif edilen sonucu sağlamaya odaklan.

## 3. Acceptance criteria

Issue'nun tamamlanmış sayılması için karşılanması gereken maddelerdir.

Örnek:

```text
- [ ] Geçerli ürün kodu ile istek başarılı sonuç döndürür.
- [ ] Bulunamayan ürün için beklenen sonuç üretilir.
- [ ] İlgili testler geçer.
```

PR açmadan önce bu maddeleri tek tek kontrol et.

Acceptance criteria'da yazmayan ek özellikler geliştirmek genellikle beklenmez.

## 4. Allowed scope

Bu Issue kapsamında değiştirebileceğin dosya veya klasörleri gösterir.

Örnek:

```text
src/NorthStarOps.Application/Catalog/Products/GetByCode/**
tests/NorthStarOps.Tests/Catalog/Products/GetByCode/**
```

Mümkün olduğunca değişikliklerini bu sınırlar içinde tut.

Bir dosyanın değiştirilmesi gerçekten gerekliyse ancak `Allowed scope` içinde değilse, kapsamı kendin genişletmeden önce Issue altında sor.

## 5. Out of scope

Bu Issue içinde yapılmaması gereken işleri açıkça belirtir.

Örnek:

```text
- Veritabanı şemasını değiştirme.
- Generated persistence dosyalarını değiştirme.
- Genel refactor yapma.
- İlgisiz endpoint veya feature ekleme.
```

`Out of scope` maddeleri, çözümü küçük ve güvenli tutmak için vardır.

## 6. Validation

Değişikliğinin doğru çalıştığını nasıl doğrulayacağını söyler.

Örnek:

```bash
dotnet build
dotnet test
```

Issue belirli bir test projesi, komut veya senaryo istiyorsa onu da çalıştır.

PR açıklamasında hangi doğrulamaları yaptığını kısa biçimde belirtmen faydalıdır.

## Canonical Issue yapısı

NorthStarOps Issue'larında temel olarak şu format kullanılır:

```md
# Amaç
Bu iş neden yapılıyor?

# Beklenen sonuç
İş tamamlandığında ne çalışıyor olmalı?

# Acceptance criteria
- [ ] ...
- [ ] ...
- [ ] ...

# Allowed scope
Değiştirilebilecek dosya veya klasörler.

# Out of scope
Bu Issue kapsamında yapılmaması gerekenler.

# Validation
Katılımcının çalıştıracağı doğrulamalar.
```

Bazı Issue'larda işin niteliğine göre ek açıklamalar bulunabilir. Ancak senden beklenen işi anlamak için önce bu altı bölümü kaynak kabul et.

## Bir şey belirsizse

Issue'yu kendi varsayımınla büyütme.

Kısa bir yorumla sorunu belirt:

```text
Allowed scope dışında şu dosyada değişiklik gerekli görünüyor. Bu dosya da kapsam dahilinde mi?
```

Bu yaklaşım hem seni gereksiz işten korur hem de başka katkılarla çakışma riskini azaltır.

## Claim etmeden önce kısa kontrol

```text
Issue status: available mı?
→ Amaç ve beklenen sonuç net mi?
→ Acceptance criteria anlaşılır mı?
→ Allowed scope belli mi?
→ Out of scope sınırlarını biliyor musun?
→ Validation adımlarını çalıştırabilecek misin?
```

Hepsi netse [`/claim` rehberine](claim-an-issue.md) geçebilirsin.
