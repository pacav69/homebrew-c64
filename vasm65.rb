class Vasm65 < Formula
  desc "VASM for C64 and 6502 CPUs"
  homepage 'http://sun.hasenbraten.de/vasm/'
  url 'http://todi.se/brew/vasm/1.8e/vasm.tar.gz'
  version '1.8e'
  sha256 '40066af65885860e5ac28fb096abeb70492a8314d97558af30a5bfa119b3edd0'

  def install
    system "mkdir -p obj"

    inreplace 'Makefile' do |s|
      s.change_make_var! 'COPTS', "-c -O2 -DOUTAOUT -DOUTBIN -DOUTELF -DOUTHUNK -DOUTSREC -DOUTTOS -DOUTVOBJ #{ENV.cflags}"
      s.change_make_var! 'LDFLAGS', "-lm #{ENV.ldflags}"
    end

    system "make CPU=6502 SYNTAX=mot vasm6502_mot"
    bin.install "vasm6502_mot"
  end
end
