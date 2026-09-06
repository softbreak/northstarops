# Draft Pull Request Açma

Claim kabul edildikten sonra **24 saat içinde** ilgili Issue için bir Draft Pull Request açmalısın.

Draft PR, işin tamamlandığı anlamına gelmez. Amaç çalışmanın başladığını görünür hale getirmek ve claim süresini karşılamaktır.

Önce [çalışma ortamını hazırla](prepare-workspace.md), ardından değişikliklerini [commit edip push et](commit-and-push.md).

## Draft PR oluştur

Kendi fork'undaki Issue branch'inden `softbreak/northstarops` reposunun `main` branch'ine Draft Pull Request aç.

## PR başlığı

Commit mesajlarında olduğu gibi Conventional Commit tipi İngilizce, açıklama Türkçe kullan:

```text
feat: ürün sorgulamasını ekle
fix: ürün bulunamadı davranışını düzelt
```

## PR açıklaması

Kısa bir özet, yaptığın doğrulamalar ve Issue bağlantısı yeterlidir:

```md
## Özet
- Yapılan değişikliği kısa şekilde açıkla.

## Doğrulama
- [ ] dotnet build
- [ ] dotnet test

Closes #12
```

Her PR tam olarak **1 Issue** ile ilişkilendirilmelidir.

## Draft PR açıldıktan sonra

Çalışmaya aynı branch ve aynı PR üzerinden devam et. Yeni bir PR açma.

Draft PR kabul edildiğinde Issue contribution sürecinde review aşamasına alınabilir; ancak aktif inceleme, PR **Ready for review** durumuna getirildikten sonra başlar.

## Ready for review ne zaman?

Aşağıdakiler tamamlandığında Draft PR'ı **Ready for review** yap:

- Issue acceptance criteria karşılandı.
- Issue kapsamı dışına çıkılmadı.
- Validation adımları çalıştırıldı.
- PR açıklaması güncel.

Review sırasında değişiklik istenirse [Changes requested rehberine](respond-to-changes-requested.md) göre aynı PR üzerinden devam et.