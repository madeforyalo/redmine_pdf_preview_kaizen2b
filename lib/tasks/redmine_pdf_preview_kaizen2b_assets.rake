# frozen_string_literal: true
require 'fileutils'

namespace :redmine_pdf_preview_kaizen2b do
  desc 'Copia PDF.js a public/plugin_assets para servirlo por Nginx/Apache'
  task assets: :environment do
    plugin_id   = 'redmine_pdf_preview_kaizen2b'
    plugin_root = File.expand_path('../../', __dir__) # => plugin root
    src         = File.join(plugin_root, 'assets', 'pdfjs')
    dest        = File.join(Rails.root.to_s, 'public', 'plugin_assets', plugin_id, 'pdfjs')

    unless Dir.exist?(src)
      abort "No existe el origen: #{src}. ¿Copiaste pdfjs/{web,build} dentro del plugin?"
    end

    FileUtils.mkdir_p(dest)
    # copia todo el contenido de assets/pdfjs/ al destino
    FileUtils.cp_r(Dir.glob(File.join(src, '*')), dest, verbose: true, remove_destination: true)

    puts "\n✅ PDF.js copiado a: #{dest}"
  end

  desc 'Elimina los assets instalados de public/plugin_assets'
  task clean: :environment do
    dest_root = File.join(Rails.root.to_s, 'public', 'plugin_assets', 'redmine_pdf_preview_kaizen2b')
    if Dir.exist?(dest_root)
      FileUtils.rm_rf(dest_root, secure: true)
      puts "🧹 Eliminado: #{dest_root}"
    else
      puts 'Nada para limpiar.'
    end
  end
end
