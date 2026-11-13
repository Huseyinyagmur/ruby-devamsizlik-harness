# Claude Code konuşma kayıtlarından token ve tur sayısını çıkarır.
# Kullanım: ruby token_say.rb
# Son 10 konuşmayı (en yenisi en altta) listeler.
require "json"

klasor = File.join(Dir.home, ".claude", "projects")
dosyalar = Dir.glob(File.join(klasor, "*", "*.jsonl")).sort_by { |f| File.mtime(f) }.last(10)

if dosyalar.empty?
  puts "Kayıt bulunamadı: #{klasor}"
  exit 1
end

dosyalar.each do |dosya|
  girdi = cikti = cache_okuma = cache_yazma = kullanici_mesaji = 0
  gorulen = {}

  File.foreach(dosya, encoding: "UTF-8") do |satir|
    j = begin
      JSON.parse(satir)
    rescue JSON::ParserError
      next
    end
    m = j["message"]
    next unless m.is_a?(Hash)

    # Sizin yazdığınız mesajlar (araç sonuçları ve /komutlar hariç)
    if j["type"] == "user"
      icerik = m["content"]
      metin = icerik.is_a?(String) ? icerik : Array(icerik).select { |b| b.is_a?(Hash) && b["type"] == "text" }.map { |b| b["text"] }.join
      kullanici_mesaji += 1 if !metin.strip.empty? && !metin.lstrip.start_with?("<")
    end

    u = m["usage"]
    next unless u && m["id"] && !gorulen[m["id"]]

    gorulen[m["id"]] = true
    girdi       += u["input_tokens"].to_i
    cikti       += u["output_tokens"].to_i
    cache_okuma += u["cache_read_input_tokens"].to_i
    cache_yazma += u["cache_creation_input_tokens"].to_i
  end

  puts "=" * 60
  puts "Proje klasörü : #{File.basename(File.dirname(dosya))}"
  puts "Tarih         : #{File.mtime(dosya).strftime('%d.%m.%Y %H:%M')}"
  puts "Sizin mesajınız (kullanıcı turu): #{kullanici_mesaji}"
  puts "Ajan yanıtı (model çağrısı)     : #{gorulen.size}"
  puts "Girdi token   : #{girdi}"
  puts "Çıktı token   : #{cikti}"
  puts "Cache okuma   : #{cache_okuma}"
  puts "Cache yazma   : #{cache_yazma}"
  puts "TOPLAM        : #{girdi + cikti + cache_okuma + cache_yazma}"
end