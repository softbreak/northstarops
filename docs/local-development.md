# Local Development

Bu rehber, NorthStarOps'u yerel ortamınızda mümkün olan en kısa sürede çalıştırmanız için hazırlanmıştır.

## 1. Gereksinimler

Aşağıdakilerin bilgisayarınızda kurulu olması gerekir:

- Git
- .NET 10 SDK
- SQL Server

Windows üzerinde en kolay seçenek SQL Server Express veya SQL Server Developer Edition'dır.

Kurulumları doğrulamak için:

```bash
git --version
dotnet --version
```

`.NET 10` kullandığınızdan emin olun.

## 2. Repoyu klonlayın

Kendi fork'unuz üzerinden çalışıyorsanız fork adresinizi kullanın.

```bash
git clone https://github.com/<github-kullanici-adiniz>/northstarops.git
cd northstarops
```

Sadece projeyi yerelde incelemek istiyorsanız ana repoyu da klonlayabilirsiniz:

```bash
git clone https://github.com/softbreak/northstarops.git
cd northstarops
```

## 3. NuGet paketlerini yükleyin

Repo kökünde:

```bash
dotnet restore
```

Komut hatasız tamamlanmalıdır.

## 4. NorthStarOps veritabanını oluşturun

Repo içindeki canonical SQL scriptini SQL Server üzerinde çalıştırın:

```text
database/NorthstarOps-full-build.sql
```

Script tamamlandığında son doğrulama çıktısında aşağıdakileri görmelisiniz:

```text
ValidationStatus = PASS
TableCount       = 38
```

Bu iki değer oluşmuyorsa uygulamayı çalıştırmadan önce veritabanı kurulumunu düzeltin.

## 5. Connection string'i User Secrets ile tanımlayın

Connection string'i `appsettings.json` veya başka bir repo dosyasına yazmayın.

Repo kökünde aşağıdaki komutlardan ortamınıza uygun olanı çalıştırın.

### SQL Server Express

```bash
dotnet user-secrets set "ConnectionStrings:NorthStarOps" "Server=.\SQLEXPRESS;Database=NorthstarOps;Trusted_Connection=True;TrustServerCertificate=True" --project src/NorthStarOps.Api
```

### LocalDB

```bash
dotnet user-secrets set "ConnectionStrings:NorthStarOps" "Server=(localdb)\MSSQLLocalDB;Database=NorthstarOps;Trusted_Connection=True;TrustServerCertificate=True" --project src/NorthStarOps.Api
```

### Default SQL Server instance

```bash
dotnet user-secrets set "ConnectionStrings:NorthStarOps" "Server=.;Database=NorthstarOps;Trusted_Connection=True;TrustServerCertificate=True" --project src/NorthStarOps.Api
```

User Secrets yalnızca sizin bilgisayarınızda tutulur ve Git'e eklenmez.

## 6. API'yi çalıştırın

Repo kökünde:

```bash
dotnet run --project src/NorthStarOps.Api
```

Başarılı olduğunda buna benzer bir çıktı görmelisiniz:

```text
Now listening on: http://localhost:5000
Hosting environment: Development
```

Tarayıcıdan aşağıdaki adresi açın:

```text
http://localhost:5000
```

API çalışıyorsa servis durumunu bildiren bir JSON yanıtı görürsünüz.

## 7. Build ve test doğrulaması

Kod değişikliğine başlamadan önce baseline'ın temiz olduğunu doğrulayın:

```bash
dotnet build
dotnet test
```

`dotnet build` hatasız tamamlanmalıdır.

Test sayısı proje geliştikçe artacaktır. Bir Issue üzerinde çalışıyorsanız o Issue'nun acceptance criteria bölümünde belirtilen testleri de çalıştırın.

## 8. Sık karşılaşılan sorunlar

### `ConnectionStrings:NorthStarOps` tanımlı değil

Önce User Secrets kaydını kontrol edin:

```bash
dotnet user-secrets list --project src/NorthStarOps.Api
```

Listede `ConnectionStrings:NorthStarOps` görünmüyorsa 5. adımdaki komutu tekrar çalıştırın.

### SQL Server'a bağlanamıyorum

Connection string içindeki `Server` değerinin bilgisayarınızdaki gerçek SQL Server instance adıyla eşleştiğinden emin olun.

Örnekler:

```text
.\SQLEXPRESS
(localdb)\MSSQLLocalDB
.
```

### `NorthstarOps` veritabanı bulunamadı

`database/NorthstarOps-full-build.sql` scriptini ilgili SQL Server instance üzerinde çalıştırdığınızdan emin olun.

### API Development ortamında başlamıyor

Repo ile birlikte gelen `src/NorthStarOps.Api/Properties/launchSettings.json` dosyası `dotnet run --project src/NorthStarOps.Api` sırasında Development ortamını otomatik olarak ayarlar.

## Contributor sınırı

Normal contributor akışında EF Core scaffold çalıştırmanız veya generated persistence dosyalarını değiştirmeniz gerekmez.

Issue açıkça istemediği sürece aşağıdaki alanlara dokunmayın:

```text
NorthStarOps.sln
src/NorthStarOps.Api/Program.cs
src/NorthStarOps.Persistence/**
database/**
```

Katkı yaparken önce claim ettiğiniz Issue'nun `Allowed scope` ve `Out of scope` bölümlerini okuyun ve değişikliklerinizi yalnızca belirtilen sınırlar içinde tutun.
