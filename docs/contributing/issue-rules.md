# Issue Üzerinde Çalışma Kuralları

Bu kurallar katkı sürecini zorlaştırmak için değil, aynı anda birden fazla kişinin güvenli ve öngörülebilir şekilde çalışabilmesi için vardır.

## 1. Yalnızca `status: available` olan Issue'yu seç

Bir Issue üzerinde çalışmaya başlamadan önce `status: available` label'ına sahip olduğundan emin ol.

Issue zaten `status: claimed` veya `status: in-review` durumundaysa o iş üzerinde paralel çalışma başlatma.

## 2. Çalışmaya başlamadan önce `/claim` kullan

İlgili Issue'nun yorum alanına yalnızca şunu yaz:

```text
/claim
```

Claim kabul edilmeden branch, kod değişikliği veya Pull Request başlatma.

Aynı anda yalnızca **1 aktif claim** taşıyabilirsin.

## 3. 24 saat içinde Draft Pull Request aç

Claim kabul edildikten sonra 24 saat içinde ilgili Issue'ya bağlı bir **Draft Pull Request** açmalısın.

Draft PR'ın bu aşamada tamamlanmış olması gerekmez. Amaç, çalışmanın gerçekten başladığını ve hangi yönde ilerlediğini görünür hale getirmektir.

PR açıklamasında ilgili Issue'yu şu biçimde bağla:

```text
Closes #123
```

## 4. Issue kapsamının dışına çıkma

Her Issue mümkün olduğunca sınırlı bir işi tarif eder.

Issue içindeki şu bölümler varsa onları kaynak kabul et:

- `Acceptance criteria`
- `Allowed scope`
- `Out of scope`

İşi tamamlamak için gerekli olmayan refactor, yeniden adlandırma, klasör taşıma veya mimari değişiklik ekleme.

Kapsamın genişlemesi gerektiğini düşünüyorsan önce Issue altında sor.

## 5. Korunan alanlara yalnızca Issue açıkça istiyorsa dokun

Normal contributor Issue'larında aşağıdaki alanları değiştirme:

```text
NorthStarOps.sln
.github/**
src/NorthStarOps.Api/Program.cs
src/NorthStarOps.Persistence/**
database/**
```

Bir Issue bu alanlardan birinde değişiklik yapılmasını açıkça istiyorsa, o Issue'nun kapsamı geçerlidir.

## 6. Aynı Issue için aynı branch ve aynı PR üzerinden devam et

Bir Issue için ikinci bir Pull Request açma.

Review sırasında değişiklik istenirse mevcut branch üzerinde düzeltme yap ve aynı PR'a push et.

Temel kural:

```text
1 Issue → 1 branch → 1 Pull Request
```

## 7. Build ve ilgili testleri çalıştır

PR göndermeden önce en azından:

```bash
dotnet build
dotnet test
```

komutlarını çalıştır.

Issue belirli bir test veya doğrulama istiyorsa acceptance criteria'daki kontrolü de uygula.

Ekstra ve ilgisiz test altyapısı kurman beklenmez.

## 8. AI araçları kullanılabilir

Kod üretimi, araştırma veya problem çözme sırasında AI araçları kullanabilirsin.

Ancak gönderdiğin değişiklikten sen sorumlusun. Review sırasında yaptığın değişikliği açıklayabilmeli ve istenen düzeltmeleri uygulayabilmelisin.

## 9. Emin değilsen kapsamı büyütme

Issue'da belirsiz bir nokta varsa varsayım yaparak daha büyük bir çözüm üretmek yerine Issue altında kısa bir soru sor.

Küçük ve doğru bir katkı, kapsamı gereksiz büyütülmüş bir katkıdan daha değerlidir.

## Kısa özet

Katkı verirken şunları hatırla:

```text
Available Issue seç
→ /claim
→ yalnız Issue kapsamındaki değişikliği yap
→ 24 saat içinde Draft PR aç
→ aynı PR üzerinden review düzeltmelerini tamamla
→ merge'i bekle
```

Sonraki adım için [`/claim` rehberine](claim-an-issue.md) geçebilirsin.
