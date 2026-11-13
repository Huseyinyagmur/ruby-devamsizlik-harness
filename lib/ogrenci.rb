# frozen_string_literal: true

# Bir öğrencinin adı, durumu ve oturum cinsinden devamsızlığı.
class Ogrenci
  DURUMLAR = %i[aktif donduruldu mezun].freeze
  TOPLAM_OTURUM = 10
  DEVAMSIZLIK_ARALIGI = (0..TOPLAM_OTURUM).freeze

  attr_reader :ad, :durum, :devamsizlik

  def initialize(ad:, durum:, devamsizlik:)
    unless DURUMLAR.include?(durum)
      raise ArgumentError, "geçersiz durum: #{durum.inspect} (#{DURUMLAR.join(', ')} olmalı)"
    end
    unless devamsizlik.is_a?(Integer) && DEVAMSIZLIK_ARALIGI.cover?(devamsizlik)
      raise ArgumentError, "devamsızlık #{DEVAMSIZLIK_ARALIGI} aralığında tamsayı olmalı: #{devamsizlik.inspect}"
    end

    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  DURUMLAR.each do |d|
    define_method(:"#{d}?") { durum == d }
  end
end
