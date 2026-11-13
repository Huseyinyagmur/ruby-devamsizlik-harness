# AGENTS.md — Anayasa

## Ortam
1. Ruby 3.4 kullan (`.ruby-version`). Yalnızca stdlib + Minitest kullan; harici gem ekleme.

## Arayüz
2. `lib/ogrenci.rb` içinde `class Ogrenci` yaz: `Ogrenci.new(ad:, durum:, devamsizlik:)`.
3. `Ogrenci::DURUMLAR = %i[aktif donduruldu mezun]` tanımla; başka `durum` için `ArgumentError` fırlat.
4. `devamsizlik` değerini 0..10 aralığında `Integer` olarak kabul et (10 oturum); aralık dışı ya da `Integer` olmayan değer (`2.5`, `"3"`) için `ArgumentError` fırlat.
5. `aktif?`, `donduruldu?`, `mezun?` metotlarını `DURUMLAR` üzerinden `define_method` ile üret.
6. `lib/devamsizlik_kontrol.rb` içinde `class DevamsizlikKontrol` yaz: `DevamsizlikKontrol.new(ogrenci)`.
7. `riskli?` → `devamsizlik >= 3`. Tam 3 (%30) RİSKLİDİR. `>` kullanma.
8. `kaldi?` → `devamsizlik >= 4`. `riskli?` ile `kaldi?` ayrı kurallardır; birleştirme.
9. `telafi_gerekir?` → `durum == :aktif && devamsizlik == 2`. Bu üçüncü kuralı atlama.
10. `sonuclar` → geçerli kuralların sembol dizisini döndür, sıra: `[:riskli, :kaldi, :telafi_gerekir]` alt kümesi.

## Kurallar
11. Sınırları şartnamede verildiği gibi uygula; sınır kararını kullanıcıya bırakma, "isterseniz `>=` yapın" deme.
12. Birim olarak OTURUM say; saat kullanma, kullanıcıdan toplam değer sorma.
13. Kuralları tamsayı karşılaştırmasıyla yaz; float ya da yüzde hesabı yapma.
14. İş mantığını sınıflara koy; hash + düz fonksiyonla modelleme yapma.
15. `lib/` içinde `gets`, `puts`, `print`, `STDIN` kullanma; G/Ç ile iş mantığını karıştırma.

## Yasaklar
16. `method_missing` tanımlama.
17. `respond_to_missing?` tanımlama.
18. Mevcut sınıfları (`Integer`, `String`, `Object`, `Array`, `Hash`, `Kernel` ...) yeniden açma, `refine` kullanma.
19. `test/` dosyalarını ve `bin/kontrol`'ü testi geçirmek için değiştirme.

## Doğrulama
20. Her değişiklikten sonra `ruby bin/kontrol` çalıştır.
21. Çıktı `KONTROL YESIL` ve çıkış kodu 0 olmadan "bitti" deme.
