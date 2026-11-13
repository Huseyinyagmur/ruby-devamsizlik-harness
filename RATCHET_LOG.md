# RATCHET_LOG

| # | Karşılaşılan hata (A koşusu) | Kalıcı kural / test | Katman |
|---|---|---|---|
| 1 | Sınır `oran > 30` yazıldı; tam %30 (3/10) "geçti" sayıldı. | AGENTS.md #7 (`>= 3`, `>` yok); `test_3_devamsizlik_tam_yuzde_30_risklidir_ama_kalmadi`, `test_2_devamsizlik_riskli_degil` | Rehber + Sensör |
| 2 | Doğru sınır kullanıcıya bırakıldı ("öğretmeniniz öyle sayıyorsa `>=` yapın"). | AGENTS.md #11 (sınır kararını kullanıcıya bırakma); sınır testleri kararı sabitler | Rehber + Sensör |
| 3 | Oturum yerine saat kullanıldı, toplam saat kullanıcıya soruldu, float yüzde hesaplandı. | AGENTS.md #4, #12, #13; `test_float_argument_error`, `test_11_argument_error`; `bin/kontrol` lib/'de `gets`/`STDIN`/float kalıplarını reddeder | Rehber + Sensör + Kanca |
| 4 | `Ogrenci` ve `DevamsizlikKontrol` sınıfları yoktu; hash + düz fonksiyon kullanıldı. | AGENTS.md #2, #6, #14; testler iki sınıfı `require_relative` ile yükler ve `.new` ile kurar; `bin/kontrol` iki lib dosyasını zorunlu tutar | Rehber + Sensör + Kanca |
| 5 | `durum` alanı ve `aktif?`/`mezun?` metotları yoktu. | AGENTS.md #3, #5; `test_durumlar_sabiti`, `test_*_sorgulari`, `test_durum_metotlari_acikca_tanimli`, `test_gecersiz_durum_argument_error` | Rehber + Sensör |
| 6 | `riskli` ve `kaldi` ayrı değildi, tek kurala (KALDI) indirildi. | AGENTS.md #8; `test_3_...` (riskli ama kalmadı), `test_4_devamsizlik_riskli_ve_kaldi`, `test_sonuclar_3`, `test_sonuclar_4` | Rehber + Sensör |
| 7 | Üçüncü (özgün) kural yoktu. | AGENTS.md #9; `test_telafi_1_de_false`, `test_telafi_2_de_true`, `test_telafi_3_te_false`, `test_telafi_aktif_olmayan_ogrenci_2_de_false`, `test_sonuclar_2_aktif` | Rehber + Sensör |
| 8 | Test yazılmadı; iş mantığı `gets`/`puts` ile iç içeydi. | AGENTS.md #15, #20, #21; `test/ogrenci_test.rb`; `bin/kontrol` testleri koşar ve lib/'de `gets` arar; PostToolUse hook her kayıtta çalıştırır | Rehber + Sensör + Kanca |
| 9 | Ruby sürümü belirtilmedi, `.ruby-version` yoktu. | `.ruby-version` = 3.4; AGENTS.md #1 | Rehber |
