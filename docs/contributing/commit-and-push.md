# Commit ve Push

Değişikliklerini yalnız claim ettiğin Issue'nun branch'inde tut.

## 1. Değişikliklerini kontrol et

```bash
git status
```

Yalnız Issue kapsamındaki dosyaların değiştiğinden emin ol.

## 2. Gerekli dosyaları stage et

Tüm repoyu topluca stage etmek yerine yalnız ilgili dosyaları ekle:

```bash
git add <dosya-veya-klasor>
```

## 3. Commit mesajını yaz

NorthStarOps commit mesajlarında Conventional Commit tipi İngilizce, açıklama Türkçe kullanılır.

Örnekler:

```text
feat: ürün sorgulamasını ekle
fix: ürün bulunamadı davranışını düzelt
test: ürün sorgulama testlerini ekle
docs: katkı rehberini güncelle
chore: proje yapılandırmasını düzenle
```

Mesaj kısa ve yapılan değişikliği anlatacak kadar açık olmalıdır.

## 4. Branch'ini fork'una push et

İlk push için:

```bash
git push -u origin feature/<issue-number>-<short-name>
```

Sonraki commitlerde:

```bash
git push
```

Review sırasında değişiklik istenirse yeni branch veya yeni PR açma; aynı branch üzerinde commit edip yeniden push et.

Sonraki adım: [Draft Pull Request açma](open-draft-pr.md).