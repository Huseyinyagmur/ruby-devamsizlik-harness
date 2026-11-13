require "minitest/autorun"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

class OgrenciTest < Minitest::Test
  def ogrenci(devamsizlik: 0, durum: :aktif, ad: "Ayse")
    Ogrenci.new(ad: ad, durum: durum, devamsizlik: devamsizlik)
  end

  def kontrol(devamsizlik, durum: :aktif)
    DevamsizlikKontrol.new(ogrenci(devamsizlik: devamsizlik, durum: durum))
  end

  # --- Sınır: riskli? / kaldi? ---

  def test_2_devamsizlik_riskli_degil
    k = kontrol(2)
    refute k.riskli?
    refute k.kaldi?
  end

  def test_3_devamsizlik_tam_yuzde_30_risklidir_ama_kalmadi
    k = kontrol(3)
    assert k.riskli?, "3/10 = %30 RİSKLİDİR (>= 3), > kullanılmamalı"
    refute k.kaldi?
  end

  def test_4_devamsizlik_riskli_ve_kaldi
    k = kontrol(4)
    assert k.riskli?
    assert k.kaldi?
  end

  def test_0_uc_degeri
    k = kontrol(0)
    refute k.riskli?
    refute k.kaldi?
    refute k.telafi_gerekir?
    assert_equal [], k.sonuclar
  end

  def test_10_uc_degeri
    k = kontrol(10)
    assert k.riskli?
    assert k.kaldi?
    refute k.telafi_gerekir?
  end

  # --- Geçersiz girdiler ---

  def test_11_argument_error
    assert_raises(ArgumentError) { ogrenci(devamsizlik: 11) }
  end

  def test_eksi_1_argument_error
    assert_raises(ArgumentError) { ogrenci(devamsizlik: -1) }
  end

  def test_float_argument_error
    assert_raises(ArgumentError) { ogrenci(devamsizlik: 2.5) }
  end

  def test_string_argument_error
    assert_raises(ArgumentError) { ogrenci(devamsizlik: "3") }
  end

  def test_gecersiz_durum_argument_error
    assert_raises(ArgumentError) { ogrenci(durum: :silindi) }
    assert_raises(ArgumentError) { ogrenci(durum: "aktif") }
  end

  def test_anahtar_kelime_argumanlari_zorunlu
    assert_raises(ArgumentError) { Ogrenci.new(ad: "Ayse", durum: :aktif) }
  end

  # --- Durum sorgu metotları ---

  def test_durumlar_sabiti
    assert_equal %i[aktif donduruldu mezun], Ogrenci::DURUMLAR
  end

  def test_aktif_sorgulari
    o = ogrenci(durum: :aktif)
    assert o.aktif?
    refute o.donduruldu?
    refute o.mezun?
  end

  def test_donduruldu_sorgulari
    o = ogrenci(durum: :donduruldu)
    refute o.aktif?
    assert o.donduruldu?
    refute o.mezun?
  end

  def test_mezun_sorgulari
    o = ogrenci(durum: :mezun)
    refute o.aktif?
    refute o.donduruldu?
    assert o.mezun?
  end

  def test_durum_metotlari_acikca_tanimli
    tanimli = Ogrenci.instance_methods(false)
    %i[aktif? donduruldu? mezun?].each do |m|
      assert_includes tanimli, m, "#{m} define_method ile Ogrenci üzerinde tanımlanmalı"
    end
  end

  def test_bilinmeyen_metot_no_method_error
    o = ogrenci
    assert_raises(NoMethodError) { o.ucuyor? }
    refute o.respond_to?(:ucuyor?)
  end

  # --- Yasaklı hileler ---

  def test_method_missing_tanimlanmamis
    [Ogrenci, DevamsizlikKontrol].each do |sinif|
      refute sinif.private_instance_methods(false).include?(:method_missing),
             "#{sinif} method_missing tanımlamamalı"
      refute sinif.instance_methods(false).include?(:method_missing),
             "#{sinif} method_missing tanımlamamalı"
      refute sinif.private_instance_methods(false).include?(:respond_to_missing?),
             "#{sinif} respond_to_missing? tanımlamamalı"
      assert_equal BasicObject, sinif.instance_method(:method_missing).owner
    end
  end

  # --- telafi_gerekir? ---

  def test_telafi_1_de_false
    refute kontrol(1).telafi_gerekir?
  end

  def test_telafi_2_de_true
    assert kontrol(2).telafi_gerekir?
  end

  def test_telafi_3_te_false
    refute kontrol(3).telafi_gerekir?
  end

  def test_telafi_aktif_olmayan_ogrenci_2_de_false
    refute kontrol(2, durum: :donduruldu).telafi_gerekir?
    refute kontrol(2, durum: :mezun).telafi_gerekir?
  end

  # --- sonuclar ---

  def test_sonuclar_2_aktif
    assert_equal [:telafi_gerekir], kontrol(2).sonuclar
  end

  def test_sonuclar_2_mezun
    assert_equal [], kontrol(2, durum: :mezun).sonuclar
  end

  def test_sonuclar_3
    assert_equal [:riskli], kontrol(3).sonuclar
  end

  def test_sonuclar_4
    assert_equal %i[riskli kaldi], kontrol(4).sonuclar
  end

  def test_sonuclar_dizi_ve_semboller
    s = kontrol(5).sonuclar
    assert_kind_of Array, s
    assert s.all?(Symbol)
  end
end
