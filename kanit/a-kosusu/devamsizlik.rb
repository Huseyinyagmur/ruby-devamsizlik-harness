# Öğrenci Devamsızlık Kontrol Programı
# Devamsızlık sınırı: %30
# Devamsızlık oranı %30'u AŞARSA öğrenci devamsızlıktan kalır.

DEVAMSIZLIK_SINIRI = 30.0

# Pozitif tam sayı okuyana kadar tekrar sorar
def tam_sayi_oku(mesaj, en_az: 0, en_cok: nil)
  loop do
    print mesaj
    girdi = $stdin.gets
    abort("\nGiriş sonlandı.") if girdi.nil?
    girdi = girdi.strip

    if girdi.match?(/\A\d+\z/)
      sayi = girdi.to_i
      if sayi < en_az
        puts "  Hata: Değer en az #{en_az} olmalıdır."
      elsif en_cok && sayi > en_cok
        puts "  Hata: Değer en fazla #{en_cok} olabilir."
      else
        return sayi
      end
    else
      puts "  Hata: Lütfen geçerli bir tam sayı girin."
    end
  end
end

def metin_oku(mesaj)
  loop do
    print mesaj
    girdi = $stdin.gets
    abort("\nGiriş sonlandı.") if girdi.nil?
    girdi = girdi.strip
    return girdi unless girdi.empty?

    puts "  Hata: Bu alan boş bırakılamaz."
  end
end

def devamsizlik_orani(devamsiz_saat, toplam_saat)
  devamsiz_saat * 100.0 / toplam_saat
end

def durum(oran)
  oran > DEVAMSIZLIK_SINIRI ? "KALDI" : "GEÇTİ"
end

puts "=" * 50
puts "      ÖĞRENCİ DEVAMSIZLIK KONTROL PROGRAMI"
puts "      (Devamsızlık sınırı: %#{DEVAMSIZLIK_SINIRI.to_i})"
puts "=" * 50

toplam_saat = tam_sayi_oku("Dersin toplam saati: ", en_az: 1)
izin_verilen = (toplam_saat * DEVAMSIZLIK_SINIRI / 100).floor
puts "En fazla #{izin_verilen} saat devamsızlık yapılabilir."

ogrenci_sayisi = tam_sayi_oku("Öğrenci sayısı: ", en_az: 1)

ogrenciler = []
ogrenci_sayisi.times do |i|
  puts "\n#{i + 1}. öğrenci"
  ad = metin_oku("  Adı Soyadı        : ")
  devamsiz = tam_sayi_oku("  Devamsızlık (saat): ", en_az: 0, en_cok: toplam_saat)
  oran = devamsizlik_orani(devamsiz, toplam_saat)
  ogrenciler << { ad: ad, devamsiz: devamsiz, oran: oran, durum: durum(oran) }
end

# Sonuç tablosu
puts
puts "-" * 62
puts format("%-22s %12s %10s %14s", "Öğrenci", "Devamsızlık", "Oran", "Durum")
puts "-" * 62
ogrenciler.each do |o|
  kalan = izin_verilen - o[:devamsiz]
  bilgi = o[:durum] == "KALDI" ? "KALDI" : "GEÇTİ (#{kalan} saat hakkı)"
  puts format("%-22s %9d saat %9.2f%%  %s", o[:ad][0, 22], o[:devamsiz], o[:oran], bilgi)
end
puts "-" * 62

kalanlar = ogrenciler.select { |o| o[:durum] == "KALDI" }
gecenler = ogrenciler.size - kalanlar.size
ortalama = ogrenciler.sum { |o| o[:oran] } / ogrenciler.size

puts "Toplam öğrenci        : #{ogrenciler.size}"
puts "Devamsızlıktan geçen  : #{gecenler}"
puts "Devamsızlıktan kalan  : #{kalanlar.size}"
puts format("Ortalama devamsızlık  : %%%.2f", ortalama)

unless kalanlar.empty?
  puts "\nDevamsızlıktan kalan öğrenciler:"
  kalanlar.each { |o| puts "  - #{o[:ad]} (%#{format('%.2f', o[:oran])})" }
end
