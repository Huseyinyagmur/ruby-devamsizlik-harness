# frozen_string_literal: true

require_relative "ogrenci"

# Devamsızlık kuralları (10 oturum üzerinden, tamsayı karşılaştırmasıyla).
class DevamsizlikKontrol
  RISK_SINIRI = 3   # 3/10 oturum = %30 → riskli (sınır dahil)
  KALMA_SINIRI = 4  # 4/10 oturum → kaldı
  TELAFI_DEGERI = 2 # aktif öğrenci, tam 2 oturum → telafi
  KURALLAR = %i[riskli kaldi telafi_gerekir].freeze

  attr_reader :ogrenci

  def initialize(ogrenci)
    raise ArgumentError, "Ogrenci bekleniyordu: #{ogrenci.inspect}" unless ogrenci.is_a?(Ogrenci)

    @ogrenci = ogrenci
  end

  def riskli?
    ogrenci.devamsizlik >= RISK_SINIRI
  end

  def kaldi?
    ogrenci.devamsizlik >= KALMA_SINIRI
  end

  def telafi_gerekir?
    ogrenci.durum == :aktif && ogrenci.devamsizlik == TELAFI_DEGERI
  end

  def sonuclar
    KURALLAR.select { |kural| public_send(:"#{kural}?") }
  end
end
