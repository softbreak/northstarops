# Çalışma Ortamını Hazırlama

Claim kabul edildikten sonra kendi fork'un ve kendi branch'in üzerinden çalış.

## 1. Repoyu fork et

`softbreak/northstarops` reposunda **Fork** seçeneğini kullan ve kendi GitHub hesabında bir fork oluştur.

## 2. Fork'unu clone et

```bash
git clone https://github.com/<github-kullanici-adin>/northstarops.git
cd northstarops
```

## 3. Ana repoyu `upstream` olarak ekle

```bash
git remote add upstream https://github.com/softbreak/northstarops.git
git remote -v
```

`origin` kendi fork'unu, `upstream` ise ana NorthStarOps reposunu göstermelidir.

## 4. Güncel `main` branch'ini al

Yeni bir Issue'ya başlamadan önce:

```bash
git fetch upstream
git switch main
git pull --ff-only upstream main
git push origin main
```

## 5. Issue branch'ini oluştur

Branch adı şu formatta olmalı:

```text
feature/<issue-number>-<short-name>
```

Örnek:

```bash
git switch -c feature/12-product-readiness
```

Bu branch üzerinde yalnız claim ettiğin Issue'nun kapsamındaki değişiklikleri yap.

## Uygulamayı yerelde çalıştırmak için

.NET, SQL Server, veritabanı kurulumu ve User Secrets adımları için [Local Development](../local-development.md) rehberini kullan.

Sonraki adım: değişikliklerini yaptıktan sonra [commit ve push rehberine](commit-and-push.md) geç.