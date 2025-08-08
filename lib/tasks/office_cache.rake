# frozen_string_literal: true

require 'fileutils'

namespace :redmine_pdf_preview_kaizen2b do
  desc 'Clean generated Office preview cache'
  task clean_cache: :environment do
    settings = Setting['plugin_redmine_pdf_preview_kaizen2b'] || {}
    cache_dir = File.join(Rails.root, settings['cache_dir'] || 'tmp/pdf_previews')
    FileUtils.rm_rf(cache_dir)
    puts "Removed #{cache_dir}"
  end
end
