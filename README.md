# Devamsızlık Kontrolü — Harness ile A/B Koşusu

Bu repo, aynı Ruby ödevini bir yapay zekâ kodlama ajanına (Claude Code, Opus 5.5) iki kez yazdırmanın
kaydıdır:

- **A koşusu (rehbersiz):** Ajana yalnızca görev verildi; kural, test ya da kanca yoktu.
- **B koşusu (harness):** Ajan; `AGENTS.md` (kurallar), `test/ogrenci_test.rb` (sensör),
  `bin/kontrol` (denetleyici) ve PostToolUse kancasıyla çalıştı.

A'da yapılan hatalar `RATCHET_LOG.md` dosyasında kalıcı kurallara ve testlere dönüştürüldü. Bu
kurallar ve testler B koşusunun harness'ini oluşturdu.

## Şartname

Bir öğrencinin 10 oturumluk derste kaç oturuma gelmediği (`devamsizlik`, 0..10 arası `Integer`) ve
durumu (`:aktif`, `:donduruldu`, `:mezun`) verilir.

| Kural | Koşul |
|---|---|
| `riskli?` | `devamsizlik >= 3` (tam 3, yani %30, RİSKLİDİR) |
| `kaldi?` | `devamsizlik >= 4` |
| `telafi_gerekir?` | `durum == :aktif && devamsizlik == 2` (aktif ve tam 2) |

- `lib/ogrenci.rb` → `Ogrenci.new(ad:, durum:, devamsizlik:)`, `Ogrenci::DURUMLAR`, `aktif?` / `donduruldu?` / `mezun?`
- `lib/devamsizlik_kontrol.rb` → `DevamsizlikKontrol.new(ogrenci)`, yukarıdaki üç kural ve `sonuclar`
  (`[:riskli, :kaldi, :telafi_gerekir]` dizisinin sırası korunmuş bir alt kümesi)
- Geçersiz durum, aralık dışı ya da `Integer` olmayan devamsızlık değeri `ArgumentError` fırlatır.

Kuralların tamamı `AGENTS.md` dosyasındadır (`CLAUDE.md` ona bağlanan bir sembolik bağdır).

## Çalıştırma

Ruby 3.4 gerekir (`.ruby-version`). Yalnızca stdlib ve Minitest kullanılır.

```sh
ruby test/ogrenci_test.rb   # yalnızca testler
ruby bin/kontrol            # testler + lib/ statik taraması
```

## bin/kontrol Kancası

**Ne denetler?**

1. `test/**/*_test.rb` dosyalarının hepsini ayrı süreçlerde çalıştırır. Kırmızı test olursa sorun sayılır.
2. `lib/ogrenci.rb` ve `lib/devamsizlik_kontrol.rb` dosyalarının var olup olmadığına bakar.
3. `lib/` altındaki kodu (yorum satırları hariç) yasaklı kalıplar için tarar:
   `method_missing`, `respond_to_missing?`, mevcut sınıflara monkey patch (`class Integer` vb.),
   `class_eval` ile yama, `refine` / `using`, `gets` / `STDIN`, float ve yüzde hesabı
   (`2.5`, `to_f`, `Float`, `fdiv`).

**Nasıl bağlanır?** `.claude/settings.json` içinde bir PostToolUse kancası olarak tanımlanır. Claude
Code, matcher'a uyan her araç çağrısından sonra `ruby bin/kontrol` komutunu kendiliğinden çalıştırır:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|Bash",
        "hooks": [{ "type": "command", "command": "ruby bin/kontrol" }]
      }
    ]
  }
}
```

**Çıkış kodları:**

- `0` → `KONTROL YESIL`; sorun yoktur.
- `2` → `KONTROL KIRMIZI`; sorunlar STDERR'e yazılır. Claude Code'da PostToolUse kancasının exit 2
  ile bitmesi, STDERR çıktısının ajana geri bildirim olarak verilmesi anlamına gelir. Böylece ajan
  hatayı görür ve düzeltmek zorunda kalır. (Araç çağrısı zaten çalışmış olduğundan geri alınmaz.)

**Bilinen açık (düzeltildi):** B koşusunda matcher `Edit|Write|MultiEdit` idi. Ajan `lib/`
dosyalarını `cat > lib/...` heredoc'uyla, yani Bash üzerinden yazdığı için kanca tetiklenmedi.
`bin/kontrol` komutunu ajan, AGENTS.md #20'ye uyarak kendisi çalıştırdı. Bu açıktan sonra matcher'a
`Bash` eklendi, AGENTS.md'ye #22 yazıldı ve RATCHET_LOG'a 10. satır olarak işlendi.

## A/B Koşusu ve Ölçüm Raporu

| | A (rehbersiz) | B (harness) |
|---|---|---|
| Kullanıcı mesajı | 1 | 1 |
| Model çağrısı | 3 | 3 |
| Çıktı token | 2.959 | 2.223 |
| Girdi + cache token | 128.564 | 144.747 |
| Toplam token | 131.523 | 146.970 |
| Şartnameye uyum | 9 hata (RATCHET_LOG) | 27/27 test yeşil, KONTROL YESIL |
| Harness kurulumu (tek seferlik) | — | 503.038 token |

**A koşusunda kullanılan Ruby sözdizimi:** Sınıf yoktu; tek dosyalık prosedürel betik.
Üst seviye `def` fonksiyonları (`tam_sayi_oku`, `durum`), anahtar kelime argümanları
(`en_az:`, `en_cok:`), `loop do` + `$stdin.gets` ile girdi okuma, sonuçlar `Hash` dizisinde
(`{ ad:, devamsiz:, oran:, durum: }`), float yüzde (`* 100.0 /`) ve üçlü operatörle
`oran > DEVAMSIZLIK_SINIRI ? "KALDI" : "GEÇTİ"`. `method_missing` ve monkey patch kullanmadı.
B koşusunda: iki sınıf, `define_method`, `attr_reader`, keyword `initialize`, tamsayı karşılaştırması.

**Yorum:** Harness tur sayısını düşürmedi; iki koşu da 3 model çağrısında bitti. A'daki ajan hiç
iterasyon yapmadan yanlış kodu tek seferde teslim etti (tam 3 devamsızlığı "geçti" saydı). B, %11,7
daha fazla tokenla, aynı tur sayısında ve ilk seferde doğru sonuç verdi; çıktı tokenı %25 azaldı.
A'nın doğru sonuca ulaşması için gereken ek turlar ölçülmedi. Yani kazanç tokende değil,
doğruluktadır. Harness kurulumu tek seferliktir ve sonraki koşularda tekrar ödenmez.

**Koşullar:** Opus 5.5, Claude Code. A, VS Code eklentisinde varsayılan izin modunda; B, terminalde
auto modda çalıştırıldı.

Ölçümlerin ham çıktısı `kanit/token_olcumleri.txt` dosyasındadır.

## Kanıtlar

`kanit/` klasörü:

| Yol | İçerik |
|---|---|
| `kanit/a-kosusu/devamsizlik.rb` | A koşusunun ham çıktısı (`C:\RubyOdev\devamsizlik.rb`, değiştirilmedi) |
| `kanit/loglar/a-kosusu_*.jsonl` | A koşusunun ham Claude Code konuşma kaydı |
| `kanit/loglar/harness-kurulumu_*.jsonl` | Harness kurulum oturumunun ham kaydı |
| `kanit/loglar/b-kosusu_*.jsonl` | B koşusunun ham kaydı |
| `kanit/token_olcumleri.txt` | `token_say.rb` ile alınmış ölçüm çıktısı |
| `kanit/token_say.rb` | Ölçüm betiği (`C:\Token\token_say.rb`) |

Git commit geçmişindeki sıra:

1. `9a7eb60` — Harness: AGENTS.md, testler, bin/kontrol, RATCHET_LOG (önce harness kuruldu)
2. `b682ee1` — B koşusu: ajanın harness ile yazdığı `lib/` (KONTROL YESIL)
3. Ardından kanıt klasörü, kanca iyileştirmesi ve bu README eklendi.

## Yapamadıklarım

- A'yı düzeltme turlarıyla şartnameye getirip toplam maliyetini ölçmedim.
- Claude'u abonelikle kullandığım için USD maliyetini ölçemedim; yalnızca token ölçtüm.
- Her koşu yalnızca bir kez yapıldı; istatistiksel tekrar yok.
- Kanca B koşusunda Bash ile yapılan yazmayı kaçırdı (sonradan düzeltildi; bkz. RATCHET_LOG #10).
